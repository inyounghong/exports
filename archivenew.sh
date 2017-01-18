#!/bin/bash
Fandom="Sherlock"
Folder="sherlock"



#overview

totals() {
	mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
		.aggregate([
		     {
		       $group: {
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
		]).toArray())' > $1
}

overview() {
	echo "{" > $1
	echo "\"Fandom\": \""$Fandom'"' >> $1

	addLine "Total" '' $1
	addLine "No Relationship" '{relationships : []}' $1
	addLine "Relationship" '{characters : { $ne : []}}' $1
	addLine "Oneshots" '{chapters : 1, iswip : 0}' $1
	addLine "Multichaptered" '{$or : [{chapters : {$gt : 1}}, {chapters: 1, iswip: 1}] }' $1
	addLine "Completed" '{iswip : 0}' $1
	addLine "WIP" '{iswip : 1}' $1
	addLine "Completed2" '{$or : [{chapters : {$gt : 1}, iswip: 1}, {chapters: 1, iswip: 1}]}' $1
	addLine "WIP2" '{$or : [{chapters : {$gt : 1}, iswip: 0}, {chapters: 1, iswip: 0}]}' $1
	echo "}" >> $1 # end json
}

addLine()
{
    echo ",\n\"$1\":" >> $3
    mongo --quiet archive --eval 'db.getCollection("'"$Fandom"'").count('"$2"')'  >> $3
}


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
    mostPopularPerYear $1 '2016' $Folder/year/$1_2016.json
    mostPopularPerYear $1 '2015' $Folder/year/$1_2015.json
    mostPopularPerYear $1 '2014' $Folder/year/$1_2014.json
    mostPopularPerYear $1 '2013' $Folder/year/$1_2013.json
}

getStats() {
    mongo --quiet archive --eval 'printjson(db.getCollection("'"$Fandom"'")
    .aggregate([
        { "$unwind" : "$'"$1"'" },
        { "$group" : {
            _id:"$'"$1"'",
            count: {$sum: 1},
            word_sum: {$sum: "$words"},
            kudo_average: {$avg: "$kudos"},
            comment_average: {$avg: "$comments"},
            word_average: {$avg: "$words"},
            }
        },
        { $match: {count: {$gt: 100}}},
        { $sort: {'"$2"'}},
        { $limit: 100 }
    ]).toArray())' > $3
}

# buckets

bucket '"$kudos"' '[ 0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500]' '"kudos"' $Folder/overview/kudos.json
bucket '"$words"' '[ 0, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000, 110000]' '"words"' $Folder/overview/words.json



getStats "categories" '"count":-1' $Folder/stats/category_count.json
getStats "rating" '"count":-1' $Folder/stats/rating_count.json
getStats "characters" '"count":-1' $Folder/stats/characters_count.json
getStats "relationships" '"count":-1' $Folder/stats/relationships_count.json
getStats "language" '"count":-1' $Folder/stats/language_count.json

# overview

overview $Folder/overview/overview.json
totals $Folder/overview/totals.json

#year

getMostPopularPerYear 'tags'
getMostPopularPerYear 'characters'
getMostPopularPerYear 'relationships'
getMostPopularPerYear 'fandoms'
