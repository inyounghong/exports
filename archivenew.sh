#!/bin/bash
Fandom="Attack on Titan"
Folder="aot"



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
	echo "}" >> $1 # end json
}

addLine()
{
    echo ",\n\"$1\":" >> $3
    mongo --quiet archive --eval 'db.getCollection("'"$Fandom"'").count('"$2"')'  >> $3
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


getStats "categories" '"count":-1' $Folder/stats/category_count.json
getStats "rating" '"count":-1' $Folder/stats/rating_count.json
getStats "characters" '"count":-1' $Folder/stats/characters_count.json
getStats "relationships" '"count":-1' $Folder/stats/relationships_count.json

# overview

# overview $Folder/overview/overview.json
# totals $Folder/overview/totals.json

#year

# getMostPopularPerYear 'tags'
# getMostPopularPerYear 'characters'
# getMostPopularPerYear 'relationships'
# getMostPopularPerYear 'fandoms'
