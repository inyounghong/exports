#!/bin/bash
Fandom="Harry Potter"

mostPopularPerYear() {
    mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .aggregate([
        { $match: {"dateUpdated": {$ne : null}}},
        { "$unwind" : "$'"$1"'"},
        {
           $project: {
               year: {$year: "$dateUpdated"},
               '"$1"': "$'"$1"'",
           }
       },
       { $match : {"year": '"$2"'}},
       { "$group" : {
            _id: {
                '"$1"': "$'"$1"'",
                year: "$year",
            },
            count: {$sum: 1},
            }
        },
        { $sort: {"count": -1}},
        { $limit: 100 },
        { $project: {
            _id: "$_id.'"$1"'",
            year: "$_id.year",
            count: "$count",
        }}
    ]).toArray())' > $3
}

getMostPopularPerYear() {
    mostPopularPerYear $1 '2016' year_$1_2016.json
    mostPopularPerYear $1 '2015' year_$1_2015.json
    mostPopularPerYear $1 '2014' year_$1_2014.json
    mostPopularPerYear $1 '2013' year_$1_2013.json
}

getMostPopularPerYear 'tags'
getMostPopularPerYear 'characters'
getMostPopularPerYear 'relationships'
getMostPopularPerYear 'fandoms'


bucket() {
    mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
        .aggregate ( [ 
            {
            $bucket: {
                groupBy: '"$1"',
                boundaries: '"$2"',
                default: "Other",
                output: {
                    '"$3"': { $sum: 1 },
                }
            }
        }
    ]).toArray())' > $4
}

bucket '"$kudos"' '[ 0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000]' '"kudos"' _kudos.json
bucket '"$words"' '[ 0, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000]' '"words"' _words.json


getBasicStats() {
    mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .aggregate([
        { "$unwind" : "$'"$1"'" },
        { "$group" : {
            _id:"$'"$1"'",
            count: {$sum : 1},
            '"$2"'
            }
        },
        { $sort: {'"$3"':-1}},
        { $match : {count: {$gt : '"$5"' }}},
        { $limit: 50 }
    ]).toArray())' > $4
}

getBasicStats "characters" "" 'count' pop_char_count.json "500"
getBasicStats "characters" 'words: { $sum : "$words" },' 'words' pop_char_words.json "500"
getBasicStats "characters" 'kudos: { $avg : "$kudos" },' 'kudos' pop_char_kudos.json "500"

getBasicStats "relationships" "" 'count' pop_ship_count.json "100"
getBasicStats "relationships" 'words: { $sum : "$words" },' 'words' pop_ship_words.json "100"
getBasicStats "relationships" 'kudos: { $avg : "$kudos" },' 'kudos' pop_ship_kudos.json "100"

getBasicStats "fandoms" "" 'count' pop_fandom_count.json "50"
getBasicStats "fandoms" 'words: { $sum : "$words" },' 'words' pop_fandom_words.json "50"
getBasicStats "fandoms" 'kudos: { $avg : "$kudos" },' 'kudos' pop_fandom_kudos.json "50"

getBasicStats "tags" "" 'count' pop_tag_count.json "20"





exit

            # word_sum: {$sum: "$words"},
            # kudo_sum: {$sum: "$kudos"},
            # comment_sum: {$sum: "$comments"},
            # hit_sum: {$sum: "$hits"},
            # kudo_average: {$avg: "$kudos"},
            # comment_average: {$avg: "$comments"},
            # hit_average: {$avg: "$hits"},
            # word_average: {$avg: "$words"},
            # chapter_average: {$avg: "$chapters"},
            # wip_average: {$avg: "$iswip"}