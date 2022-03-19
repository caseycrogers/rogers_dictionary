git rev-parse HEAD > assets/git_commit.txt;
sha1sum assets/dictionaryV* | grep -o '^[^ ]*' > assets/database_hash.txt;

