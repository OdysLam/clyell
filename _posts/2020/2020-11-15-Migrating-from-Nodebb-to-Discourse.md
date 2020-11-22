---
layout: post
title:	Migrating from Nodebb to Discourse
date: 2020-11-15
author: "Odysseas Lamtzidis"
tags:
    - "2020"
    - "developer-relations"
    - "tutorial"
excerpt: "Migrating a live forum from Nodebb to Discourse"
image: https://i.imgur.com/hWeP9ld.png
vertical: developer-relations
---

![](https://i.imgur.com/hWeP9ld.png)

# Migrating from Nodebb to Discourse

# Some background

When I joined Netdata in early August, we had just released our forum, based on Nodebb.

According to Nodebb creators: 

> NodeBB is a next-generation discussion platform that utilizes web sockets for instant interactions and real-time notifications. NodeBB forums have many modern features out of the box such as social network integration and streaming
discussions.

The premise of a well-engineered product was proven true, as nodebb is an extremely pleasant software to work with, offering a modern technological stack which is easily extensible and using npm to vendor it's plugins.

On top of that, the plugins can be installed without rebuilding the forum, meaning that you can swap them on-the-fly. Great!

The reason we chose to move-out of Nodebb is that although the project is awesome and the community is vivid, it's also not very popular as Discourse. This translates to Discourse having a greater number of available plugins and themes. Our community quickly grew with new requirements that would be hard to accommodate

This means that in order to bring the forums up to shape, there is more manual work and maintenance required. Which would have been great, since the choice of customization is really wonderful, but Netdata is running a skeleton crew at the moment. Thus whatever development I need, I will do it myself, limiting considerably the time I can invest.

Moreover, as I have now spent considerable time in Discourse, while I do prefer some elements of NodeBB, such as the technology stack or the plugin system, Discourse as a whole offers much more control and options.

All in all, there is a reason while the grand majority of forums look identical nowadays. 

## The migration

In order to migrate, the good folks at Discourse, with the [help of the community](https://meta.discourse.org/t/importing-nodebb-mongodb-to-discourse/126553/11), have released a migration tool which parses the MongoDB/Redis database of Nodebb and extracts what can be extracted.

Although the process seemed to be easy, there are a few gotchas which I learned the hard way.

1) You have to build Discourse from source. As it's a great piece of monolithic software on Ruby, it's not as trivial as one would have hoped. 
    1) MacOS is not playing nice with Ruby, avoid to reduce unneeded complexity.
    2) Go for Ubuntu and prepare to spend quite some time in order to setup everything.
2) When dumping the MongoDB database, make sure you save everything on the correct directory. In case of a hosted NodeBB, make sure that you request the **entirety** of the dump. I spent quite some time trying to figure out why the migration did not work, partly because I requested half the dump.
3) In case you encounter the ` don't know what to do with file, skipping` error, this means that you are using a newer version of mongorestore which has a slightly  different syntax.
	1) Try `mongorestore -d <database_name> /directory`
	2) This will restore the database in a newly created database called `<database_name>`.
	3) Make sure you change the `nodebb.rb` line concerning the connection to the MongoDB to include the database you defined above: `@client = adapter.new('mongodb://127.0.0.1:27017/<database_name>'')`
4) It is possible that there are some bad state in MongoDB which might break the migration script. Let's see an example of what I encountered in the following section.

## The culprit is 3.14

During my community management time, I would get some bad states in the forum, meaning that some topics would be created but would be impossible to be retrieved after their creation, resulting to a 404 instead. 

As there were already discussions about the migration, I did not spend time to pin down the issue, as it was very very intermitent. 

After some time, I discovered that the reason for this was the keyword `Raspberry pi`. Our forum software did not like this keyword and would result to a bad state every single time. 

Again, I did not elect to debug the issue, as there were far more pressing issues at hand in regards to managing the Netdata community.

### We found it!

After talking with the good folks at NodeBB for this migration, I informed them of the bug, in case they wanted to dig deeper to evaluate if this is a wider problem or specific to my instance. They were very happy to investigate, and indeed they found the culprit.

They use a specific regex on their reverse proxy that checks for common file extensions that they don't serve. One of these files is `.asp` which without the ^ or $ qualifier can match with `raspberry pi`. By updating their rules, they were able to fix this.


## The migration

Unknowingly to me, this "technical debt" would come back to haunt me during the migration test run that I performed before finalizing our decision.

For some reason, the migration script was unable to perform the migration and would crash. With the help of some debugging "print" statements  that I put in the script, I found that when the script would fetch a topic, it would then start fetching it's posts.

Then, at a particular topic it would crush. When I tried to fetch that topic manually using the MongoDB CLI, I succeeded But, when I tried to fetch the first post, the CLI tool could not find it in the database.

Bingo!

Apparently, for the "Raspberry pi" topics, while the topic existed, the post did not, resulting in a `nul` return for `post_id` and the crashing of the whole script. In Nodebb, the `post_id` of the first post is the `mainPID`.

In NodeBB the first post of a topic has the same ID as the topic. Here is the data structure of the bad topic:
```JSON
{
    "_id": ObjectId("5f621635d53e46aab957f13b"),
    "_key": "topic:99",
    "cid": 3,
    "lastposttime": 1600263733946,
    "mainPid": 0,
    "postcount": 0,
    "slug": "99/monitor-pi-hole-and-a-raspberry-pi-with-netdata",
    "tid": 99,
    "timestamp": 1600263733946,
    "title": "Monitor Pi-hole (and a Raspberry Pi) with Netdata",
    "uid": 3,
    "viewcount": 2,
    "thumb": "",
    "deleted": 1,
    "deletedTimestamp": 1600263902138,
    "deleterUid": 37,
    "mergeIntoTid": 100,
    "mergedTimestamp": 1600263902160,
    "mergerUid": 37
}
```


To resolve this, again using the appropriate print statements, I found that the script initially brings a list of all the topics in the database, and then begins to parse them and extract the information it requires (content, date, etc.).

Here is the function in `mongo.rb`
```ruby
def topics(offset = 0, page_size = 2000)
      topic_keys = mongo.find(_key: 'topics:tid').skip(offset).limit(page_size).pluck(:value)

      topic_keys.map { |topic_key| topic(topic_key) }
    end
```

Thus, I assumed that if I removed the particular topic from that list of available topics, even if it exists in the database, the script will not try to import it.

I ran: `db.objects.find({_key:"topics:tid"})` which returned a large number of documents, like this one: `{ "_id" : ObjectId("5fb48402d53e46aab9f70b07"), "_key" : "topics:tid", "value" : "198", "score" : 1605665794715 }`.

Thus, I needed to delete the document with `"value":"99"`.

I ran `db.objects.remove({_key:"topics:tid", "value": "99"})` and voila, the migration script was able to progress normally.

In case you are interested, you can find the database schema on the NodeBB [website](https://docs.nodebb.org/development/database-structure/).

Here are the steps for the migration in a bite-sized format:
1. Import mongodump into local instance of Mongo.
2. Build Discourse from source and setup the discourse instance.
3. Run script which exports data from mongo, transforms them and import them to PostgreSQL.
4. Export Discourse instance through the Admin panel and import it to the production server.
	1. In case you are using a Hosted version of Discourse, you will need to contact support in order to restore the uploaded backup.
5. Make modifications and prepare forum for production use.

# Final words

A last problem that I encountered during the migration was related with the profile pictures that the script tried to import. Apparently some were pulled from the Internet and used some special characters which the script could not parse in a secure manner.

As with the [Pareto Principle](https://www.investopedia.com/terms/p/paretoprinciple.asp) of 80/20, I am pretty happy with a 80% of the perfect result. Thus, I simply *commented-out* the profile picture functions and went on with my life.

Although this will result in a *worse* user experience, as existing users will have to re-upload their profile pictures, the other option was not viable. 

Due to creating the foundations of a Developer Relations program, I have to be ruthless with prioritization, something which I have not done particularly sucesful. But, as it's a process, I learn, and thus I opted to go for the quick-and-dirty solution for this. 

In the end, what really matters is to improve the experience of the community as a whole, making sure that it grows steadily