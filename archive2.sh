#!/bin/bash


#!/bin/bash
echo "\nRunning bash for collection Harry Potter"
Fandom="Harry Potter"

mongo --quiet archive --eval 'printjson(db.getCollection("Harry Potter")
.aggregate([
    { $match: {"dateUpdated": {$ne : null}}},
    {
       $project: {
           day: { $dateToString: { format: "%m-1-%Y", date: "$dateUpdated" } },
            date: { $dateToString: { format: "%Y-%m", date: "$dateUpdated" } },
           words: "$words",
       }
   },

   { $group : {
         _id: {
             day: "$day",
             date: "$date",
        },
        "count": { $sum: 1 },
        "words": { $sum: "$words" },
        }
    },
       {$sort : {"_id.date": -1}},
]).toArray())' > per_month_count.json

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

getFandomCount() {
    mongo --quiet archive --eval 'printjson(db.getCollection("Harry Potter")
    
    .aggregate([
        { "$unwind" : "$fandoms" },
        { $group: {
            _id: "$fandoms",
            count: {$sum : 1}
            }
        },
        {$sort: {count: -1}}
    ]).toArray())' > fandom_simple.json
}

getFandomCount

# ratingPerMonth() {
# mongo --quiet archive --eval 'printjson(db.getCollection("Harry Potter")
# .aggregate([
#     {
#        $project: {
#             rating: "$rating",
#             date: { $dateToString: { format: "%Y-%m", date: "$dateUpdated" } },
#        }
#    },
#     { "$group": {
#         "_id": "$rating",
#         "date": { "$push": "$date" },
#         "total": { "$sum": 1 }
#     }},
#     { "$unwind": "$date" },
#     { "$group": {
#         "_id": {
#             "date": "$date",
#             "rating": "$_id"
#         },
#         "total": { "$first": "$total" },
#         "ratingCount": { "$sum": 1 }
#     }},


#     { $sort: { _id: -1 } },
# ]).toArray())' > rating_per_month.json
# }

# ratingPerMonth2() {
#     mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
# .aggregate([
#     {
#        $project: {
#             rating: "$rating",
#             yearMonth: { $dateToString: { format: "%Y-%m", date: "$dateUpdated" } },
#        }
#    },
#     { "$group": {
#         "_id": "$yearMonth",
#         "rating": { "$push": "$rating" },
#         "total": { "$sum": 1 }
#     }},
#     { "$unwind": "$rating" },
#     { "$group": {
#         "_id": {
#             "yearMonth": "$_id",
#             "rating": "$rating"
#         },
#         "total": { "$first": "$total" },
#         "ratingCount": { "$sum": 1 }
#     }},
#     { "$group": {
#         "_id": "$_id.yearMonth",
#         "total": { "$first": "$total" },
#         "rating": {
#             "$push": { "name": "$_id.rating", 
#                 "count": "$ratingCount" }
#         }
#     }},
    
#     { "$unwind": "$rating" },
     
#      { $sort: { "rating.name": 1} },
#          { "$group": {
#         "_id": "$_id",
#         "total": { "$first": "$total" },
#         "rating": {
#             "$push": { "name": "$rating.name", "count": "$rating.count" },
            
#         }
#     }},
    
    
#     { $sort: { _id: -1 } },
#     ]).toArray())' > rating_per_month.json
# }

fullPerMonth() {
    mongo --quiet archive --eval 'printjson(db.getCollection("Harry Potter")
.aggregate([
    
     
    {
       $project: {
            characters: "$characters",
            day: { $dateToString: { format: "%m-1-%Y", date: "$dateUpdated" } },
            yearMonth: { $dateToString: { format: "%Y-%m", date: "$dateUpdated" } },
       }
   },
    { "$group": {
        "_id": {
                yearMonth: "$yearMonth",
                day: "$day",
        },
        "characters": { "$push": "$characters" },
        "total": { "$sum": 1 }
    }},
    { "$unwind": "$characters" },
    { "$unwind": "$characters" },
    { "$group": {
        "_id": {
            "yearMonth": "$_id",
            "character": "$characters"
        },
        "total": { "$first": "$total" },
        "characterCount": { "$sum": 1 }
    }},
    { "$group": {
        "_id": "$_id.yearMonth",
        "total": { "$first": "$total" },
        "characters": {
            "$push": { "name": "$_id.character", "count": "$characterCount" }
        }
    }},
    
    { "$unwind": "$characters" },
    
    { $match : { $or : [
        {"characters.name":"Harry Potter"}, 
        {"characters.name":"Hermione Granger"},
        {"characters.name":"Draco Malfoy"},
        {"characters.name":"Newt Scamander"},
        {"characters.name":"Albus Dumbledore"},
        {"characters.name":"Ron Weasley"},
     ] } },

    { $sort: {"characters.name": 1} },
    
     { "$group": {
        "_id": "$_id",
        "total": { "$first": "$total" },
        "characters": {
            "$push": { "name": "$characters.name", "count": "$characters.count" }
        }
    }},
    
        { $sort: { "_id.yearMonth": -1 } }
    ]).toArray())' > full_per_month.json
}

fullPerMonth

getPerDay() {
    mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .aggregate([
        { $match: { '"$1"' }},
        {
           $project: {
               day: { $dateToString: { format: "%m-1-%Y", date: "$dateUpdated" } },
              yearMonth: { $dateToString: { format: "%Y-%m-%d", date: "$dateUpdated" } },
           }
       },
       { $group : {
             _id: {
                yearMonth: "$yearMonth",
                day: "$day",
            },
            count: { $sum: 1 },
            }
        },
        { $sort: { "_id.yearMonth": -1 } },
        {
           $project: {
              _id: "$_id.yearMonth",
              '"$2"': "$count",
           }
       },
    ]).toArray())' > $3
}

getPerWeek() {
	mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .aggregate([
        { $match: { '"$1"' },
        {
           $project: {
               week: {$week: "$dateUpdated" },
               month: {$month: "$dateUpdated" },
               year: {$year: "$dateUpdated" },
           }
       },
       { $group : {
             _id: {
                week: "$week",
               month: "$month",
               year: "$year",
            },
            '"$2"': { $sum: 1 },
            }
        },
        { $sort: { "_id.year": -1, "_id.week": -1 } },
    ]).toArray())' > $3
}

getPerWeek 'characters: "Newt Scamander", dateUpdated: {$ne : null}}' '"Newt Scamander"' char_newt_per_week.json


getPerMonth() {
    mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .aggregate([
        { $match: { '"$1$2"' }},
        {
           $project: {
               day: { $dateToString: { format: "%m-1-%Y", date: "$dateUpdated" } },
              yearMonth: { $dateToString: { format: "%Y-%m", date: "$dateUpdated" } },
           }
       },
       { $group : {
             _id: {
                yearMonth: "$yearMonth",
                day: "$day",
            },
            count: { $sum: 1 },
            }
        },
        { $sort: { "_id.yearMonth": -1 } },
        {
           $project: {
              _id: "$_id.day",
              '"$2"': "$count",
           }
       },
    ]).toArray())' > $3
}

getPerDay "" "\"Total\"" works_per_day.json
getPerDay "characters: \"Newt Scamander\"" "\"Newt Scamander\"" char_newt_per_day.json

# changed num parameters

getPerMonth "categories: " "\"M/M\"" cat_mm.json
getPerMonth "categories: " "\"F/M\"" cat_fm.json

getPerMonth "" "" works_per_month.json
# getPerMonth "characters: " "\"Hermione Granger\"" char_hermione_per_month.json
# getPerMonth "characters: " "\"Harry Potter\"" char_harry_per_month.json
# getPerMonth "characters: " "\"Draco Malfoy\"" char_draco_per_month.json
# getPerMonth "characters: " "\"Newt Scamander\"" char_newt_per_month.json
# getPerMonth "characters: " "\"Daphne Greengrass\"" char_daphne_per_month.json

getPerMonth "relationships: " "\"Draco Malfoy/Harry Potter\"" rel_draco_harry.json
getPerMonth "relationships: " "\"Sirius Black/Remus Lupin\"" rel_sirius_remus.json
getPerMonth "relationships: " "\"Credence Barebone/Original Percival Graves\"" rel_credence_graves.json



# works per month
# mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
# .aggregate([
#     {
#        $project: {
#           yearMonth: { $dateToString: { format: "%Y-%m", date: "$dateUpdated" } },
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
    mongo --quiet archive --eval 'db.getCollection("'"$Fandom"'").count('"$2"')'  >> overview.json
}

> overview.json

echo "{" >> overview.json
echo "\"fandom\": \"Harry Potter\"" >> overview.json

overview "total" ''
overview "no relationship" '{relationships : []}'
overview "relationship" '{characters : { $ne : []}}'
overview "oneshots" '{chapters : 1, iswip : 0}'
overview "multichaptered" '{$or : [{chapters : {$gt : 1}}, {chapters: 1, iswip: 1}] }'
overview "completed" '{iswip : 0}'
overview "wip" '{iswip : 1}'
echo "}" >> overview.json # end json




exit
