{
  if ($2=="Starts") {
    start_position = substr($5, 1, length($5)-1)
    end_position = $8
  }
  else
  {
    if (($1=="For") && ($2=="fit")) {
      aligned = aligned $5
    }
    else 
    {
       if ($2=="Gene:") {
         gene = $3
         print start_position , chromosome ":" start_position "-" end_position, gene, aligned, filenam
       }
       else {
        filenam = $1
        aligned = ""
       }
    }
  }
}