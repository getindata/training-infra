#!/usr/bin/python

import sys
import json

if __name__ == "__main__":

    # Grab the input and output
    username = sys.argv[1]
    songtsv = sys.argv[2]
    lyricsjson = sys.argv[3]
    outputdir = sys.argv[4]

    with open(lyricsjson) as f:
        lyrics_json = f.readlines()

    with open(songtsv) as f:
        songs_tsv = f.readlines()

    songs = {}
    for l in songs_tsv:
        # id title artist
        x = l.split('\t')
        song = {
	    'song_id' : int(x[0]),
	    'title' : x[1].strip(),
	    'artist' : x[2].strip()
        }
        songs[song['song_id']] = song

    lyrics = {}
    for l in lyrics_json:
        x = json.loads(l)
        try:
            sid = x['song_id']
	    x['title'] = songs[sid]['title']
	    x['artist'] = songs[sid]['artist']
	    lyrics[sid] = x
        except KeyError:
            pass

    output = open('%s/lyrics_index_%s.json' % (outputdir, username), 'w')

    for k in lyrics:
        output.write("""{ "index" : {"_index" : """ + '"streamrock_%s"' % (username) + """, "_type" : "lyrics"} }""")
	output.write("\n")
        output.write(json.dumps(lyrics[k]))
	output.write("\n")

    output.close()
