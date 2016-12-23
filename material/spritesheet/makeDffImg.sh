for file in `\find . -maxdepth 1 -name '*.png'`; do
	outfile=`echo ${file/.\//.\/df_}`
	echo "$file -> $outfile"
	ruby field_agent.rb $file $outfile --scale 0.25
done
