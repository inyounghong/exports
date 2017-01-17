#!/bin/bash
Fandom="Harry Potter"

mongo --quiet archive --eval 'printjson(db.getCollection("Harry Potter")
.aggregate ( [ 
    {
    $bucket: {
      groupBy: "$kudos",
      boundaries: [ 0, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000],
      default: "Other",
              output: {
                "count": { $sum: 1 },
            }
    }
}

]).toArray())' > _kudos.json


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