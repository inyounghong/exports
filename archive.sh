#!/bin/bash
echo "\nRunning bash for collection Harry Potter"
Fandom="Harry Potter"

getStats() {
    mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .aggregate([
        { "$unwind" : "$'"$1"'" },
        { "$group" : {
            _id:"$'"$1"'",
            count: {$sum: 1},
            kudos: {$avg: "$kudos"},
            comments: {$avg: "$comments"},
            hits: {$avg: "$hits"},
            words: {$avg: "$words"},
            chapters: {$avg: "$chapters"},
            }
        },
        { $sort: {"count":-1}}
    ]).toArray())' > $2
}

# character, count

getStats "characters" character_count.json
getStats "categories" category_count.json
getStats "relationships" relationship_count.json
getStats "fandoms" fandom_count.json

# category, count (wrapped)
# mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
# .aggregate([
#     { "$group" : {_id:"$categories", count:{$sum:1}} },
#     { $sort: {"count":-1}}
# ]).toArray())' > category_count_wrapped.json


# fandom, count
mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
.aggregate([
    { "$unwind" : "$fandoms" },
    { "$group" : {
        _id:"$fandoms",
        count: {$sum: 1},
        kudos: {$avg: "$kudos"},
        comments: {$avg: "$kudos"},
        hits: {$avg: "$hits"},
        words: {$avg: "$words"},
        chapters: {$avg: "$chapters"},
        }
    },
    { $sort: {"count":-1}}
]).toArray())' > fandom_count.json

# works per month
mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
.aggregate([
    {
       $project: {
          yearMonth: { $dateToString: { format: "%Y-%m", date: "$datePublished" } },
       }
   },
   { $group : {
        _id: "$yearMonth",
        count: { $sum: 1 },
        }
    },
    { $sort: { _id: 1 } },
]).toArray())' > works_per_month.json

# totals

mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
.aggregate([
     {
       $group:
         {
            _id: null,
            words_total: {$sum : "$words" },
            kudos_total: {$sum : "$kudos" },
            comments_total: {$sum : "$comments" },
            hits_total: {$sum: "$hits" },

            kudo_average: { $avg: "$kudos" } ,
            comments_average: { $avg: "$comments" },
            hits_average: { $avg: "$hits" },
            words_average: { $avg: "$words"}
         }
     }
]).toArray())' > totals.json

overview()
{
    echo ",\n\"$1\":" >> overview.json
    mongo --quiet archive --eval "$2" >> overview.json
}

> overview.json

echo "{" >> overview.json
echo "\"fandom\": \"Harry Potter\"" >> overview.json

overview "total" 'db.getCollection("'"$Fandom"'").count()'
overview "no relationship" 'db.getCollection("'"$Fandom"'").count({relationships : []})'
overview "oneshots" 'db.getCollection("'"$Fandom"'").count({chapters : 1, iswip : 0})'
overview "completed" 'db.getCollection("'"$Fandom"'").count({iswip : 0})'
overview "wip" 'db.getCollection("'"$Fandom"'").count({iswip : 1})'
echo "}" >> overview.json # end json




exit
