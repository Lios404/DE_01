FILE="tmdb-movies.csv"
CLEAN="tmdb-clean.csv"

echo "========== CLEAN DATA =========="

awk '
BEGIN{q=0}
{
    line=""
    for(i=1;i<=length($0);i++){
        c=substr($0,i,1)

        if(c=="\"") q=!q
        else if(c=="," && q) c=";"

        line=line c
    }

    if(q) printf "%s ", line
    else print line
}' "$FILE" > "$CLEAN"

echo "Created: $CLEAN"
awk -F',' '{print NF}' "$CLEAN" | sort | uniq -c
echo


# ==========================================
# TASK 1
# ==========================================

echo "========== TASK 1 =========="

{
    head -1 "$CLEAN"

    awk -F',' '
    NR>1{
        split($16,d,"/")
        printf "%04d%02d%02d,%s\n",$19,d[1],d[2],$0
    }' "$CLEAN" |
    sort -r |
    cut -d',' -f2-
} > task1_sorted_by_date.csv

awk -F',' 'NR<=11 && NR>1{
    printf "%-40s | %s\n",$6,$16
}' task1_sorted_by_date.csv

echo


# ==========================================
# TASK 2
# ==========================================

echo "========== TASK 2 =========="

awk -F',' '
NR==1 || $18>7.5
' "$CLEAN" > task2_high_rated.csv

echo "Movies found: $(($(wc -l < task2_high_rated.csv)-1))"

awk -F',' '
NR<=6 && NR>1{
    printf "%-40s | Rating: %s\n",$6,$18
}' task2_high_rated.csv

echo


# ==========================================
# TASK 3
# ==========================================

echo "========== TASK 3 =========="

echo "--- HIGHEST REVENUE ---"

awk -F',' '
NR>1 && $5>0{
    if($5>max){
        max=$5
        movie=$6
    }
}
END{
    printf "Movie: %s\nRevenue: %.0f USD\n",movie,max
}' "$CLEAN"

echo "--- LOWEST REVENUE ---"

awk -F',' '
NR>1 && $5>0{
    if(min==0 || $5<min){
        min=$5
        movie=$6
    }
}
END{
    printf "Movie: %s\nRevenue: %.0f USD\n",movie,min
}' "$CLEAN"

echo


# ==========================================
# TASK 4
# ==========================================

echo "========== TASK 4 =========="

awk -F',' '
NR>1 && $5>0{
    sum+=$5
    count++
}
END{
    printf "Total Revenue: %.0f USD\n",sum
    printf "Movies: %d\n",count
}' "$CLEAN"

echo


# ==========================================
# TASK 5
# ==========================================

echo "========== TASK 5 =========="

awk -F',' '
NR>1 && $4>0 && $5>0{
    profit=$5-$4
    printf "%.0f,%s\n",profit,$6
}' "$CLEAN" |
sort -t',' -k1,1nr |
head -10 |
awk -F',' '{
    printf "%-40s | Profit: %15d USD\n",$2,$1
}'

echo


# ==========================================
# TASK 6
# ==========================================

echo "========== TASK 6 =========="

echo "--- TOP DIRECTORS ---"

awk -F',' '
NR>1 && $9!=""{
    gsub(/"/,"",$9)
    print $9
}' "$CLEAN" |
sort | uniq -c | sort -rn | head -5 |
awk '{
    c=$1
    $1=""
    sub(/^ /,"")
    printf "%3d movies | %s\n",c,$0
}'

echo "--- TOP ACTORS ---"

awk -F',' '
NR>1{
    n=split($7,a,"|")
    for(i=1;i<=n;i++)
        if(a[i]!="") print a[i]
}' "$CLEAN" |
sort | uniq -c | sort -rn | head -5 |
awk '{
    c=$1
    $1=""
    sub(/^ /,"")
    printf "%3d movies | %s\n",c,$0
}'

echo


# ==========================================
# TASK 7
# ==========================================

echo "========== TASK 7 =========="

awk -F',' '
NR>1{
    n=split($14,a,"|")
    for(i=1;i<=n;i++)
        if(a[i]!="") print a[i]
}' "$CLEAN" |
sort | uniq -c | sort -rn |
awk '{
    c=$1
    $1=""
    sub(/^ /,"")
    printf "%4d movies | %s\n",c,$0
}'

echo
echo "========== DONE =========="
