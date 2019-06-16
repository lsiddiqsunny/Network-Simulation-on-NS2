#INPUT: output file AND number of iterations
output_file_format="802_11_udp";
under="_";





#iteration=$(printf %.0f $iteration_float);
read iteration
iteration_float=$iteration;
start=$iteration
end=$iteration
r=$start
while [ $r -le $end ]
do
echo "total iteration: $iteration"
###############################START A ROUND
l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;
dr_ratio=0.0;time=0.0;t_energy=0.0;
#energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;
i=0
while [ $i -lt $iteration ]
do
#################START AN ITERATION
echo "                             EXECUTING $(($i+1)) th ITERATION"
read node
read flow
read Tx_Range
read packet

ns 802_11_udp.tcl $node $flow $packet $Tx_Range $(($i+1))
echo "SIMULATION COMPLETE. BUILDING STAT......"
awk -f 802_11_udp.awk 802_11_udp.tr > "$output_file_format$under$i.out"
i=$(($i+1))
l=0
#################END AN ITERATION
done

r=$(($r+1))
#######################################END A ROUND
done



