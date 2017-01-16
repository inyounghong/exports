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
            word_sum: {$sum: "$words"},
            kudo_sum: {$sum: "$kudos"},
            comment_sum: {$sum: "$comments"},
            hit_sum: {$sum: "$hits"},
            kudo_average: {$avg: "$kudos"},
            comment_average: {$avg: "$comments"},
            hit_average: {$avg: "$hits"},
            word_average: {$avg: "$words"},
            chapter_average: {$avg: "$chapters"},
            wip_average: {$avg: "$iswip"}
            }
        },
        { $sort: {'"$3"'}},
        { $limit: 100 }
    ]).toArray())' > $2
}

getPerMonth() {
    mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .aggregate([
        { $match: { '"$1"' }},
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
    ]).toArray())' > $2
}

getPerMonth "" works_per_month.json
getPerMonth "characters:\"Hermione Granger\"" hermione_per_month.json
getPerMonth "characters:\"Harry Potter\"" harry_per_month.json
getPerMonth "characters:\"Draco Malfoy\"" draco_per_month.json
getPerMonth "characters:\"Newt Scamander\"" draco_per_month.json
getPerMonth "characters:\"Daphne Greengrass\"" draco_per_month.json


# works per month
# mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
# .aggregate([
#     {
#        $project: {
#           yearMonth: { $dateToString: { format: "%Y-%m", date: "$datePublished" } },
#        }
#    },
#    { $group : {
#         _id: "$yearMonth",
#         count: { $sum: 1 },
#         }
#     },
#     { $sort: { _id: 1 } },
# ]).toArray())' > works_per_month.json


# character, count

getStats "characters" character_count.json "\"count\":-1"
getStats "categories" category_count.json "\"count\":-1"
getStats "relationships" relationship_count.json "\"count\":-1"
getStats "fandoms" fandom_count.json "\"count\":-1"
getStats "rating" rating_count.json "\"_id\":1"
getStats "language" language_count.json "\"count\":-1"

# category, count (wrapped)
# mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
# .aggregate([
#     { "$group" : {_id:"$categories", count:{$sum:1}} },
#     { $sort: {"count":-1}}
# ]).toArray())' > category_count_wrapped.json


# All works
mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .find(
        {}, 
        {rating: 1, iswip: 1, language: 1, words: 1, chapters: 1, kudos: 1, comments: 1, hits: 1,})
).toArray())' > all_stories.json




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
