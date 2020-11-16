for FILE in $(git ls-files ./doc/*.png); do
    git grep $(basename "$FILE") > /dev/null || echo "would remove $FILE"
done
