#!/bin/bash
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

exit
