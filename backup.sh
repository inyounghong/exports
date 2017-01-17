#!/bin/bash

mongo --quiet archive --eval 'printjson(db.getCollection("Harry Potter").find().toArray())' > _backup.json