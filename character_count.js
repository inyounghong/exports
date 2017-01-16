// var db = connect('127.0.0.1:27017/archive');

res = db.getCollection("Harry Potter").aggregate([
    { "$unwind" : "$characters" },
    { "$group" : {_id:"$characters", count:{$sum:1}} },
    { $sort: {"count":-1}}
])

//iterate the names collection and output each document
while (res.hasNext()) {
   printjson(res.next())
}
