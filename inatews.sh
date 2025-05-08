MASTER_FOLDER="$(pwd)"

# Function to pad numbers with leading zeros
pad() {
    printf "%0$2d" "$1"
}

mechanism=1
region=1
magnitude_start=2
magnitude_end=2
output_dir=1

# Validate input ranges
if ((mechanism < 1 || mechanism > 3)); then
    echo "Invalid mechanism: $mechanism (must be between 1 and 3)"
    exit 1
fi
if ((region < 1 || region > 14)); then
    echo "Invalid region: $region (must be between 1 and 14)"
    exit 1
fi
if ((magnitude_start < 1 || magnitude_end > 14 || magnitude_start > magnitude_end)); then
    echo "Invalid magnitude range: $magnitude_start to $magnitude_end (must be between 1 and 14)"
    exit 1
fi

for ((magnitude = magnitude_start; magnitude <= magnitude_end; magnitude++)); do
    depth_start=1
    depth_end=1
    if ((magnitude >= 5 && magnitude <= 9)); then
        depth_end=7
    fi
    for ((depth = depth_start; depth <= depth_end; depth++)); do
        
        point_start=144
        point_end=148
	    while (($point_start <= $point_end)); do
            for ((run = 0; run <= 4; run++)); do
            (
            	if (( $(($point_start+$run)) <= $point_end));then
		            run_folder="$((${point_start}+$run))/M_${magnitude}/D_${depth}"	
        	        mkdir -p $run_folder
        	        cd run_item
        	        cp * "$MASTER_FOLDER/$run_folder"
        	        cd "$MASTER_FOLDER/$run_folder"

                    info_ps="$MASTER_FOLDER/info_PSnew1.csv"
                    info_2="$MASTER_FOLDER/nando_layer2.csv"
                    info_3="$MASTER_FOLDER/nando_layer3.csv"

                    tail -n +2 "$info_ps" | while IFS=, read -r order Level position Longitude Latitude dep str dip thk unc lon_index
                    do
                        # Use the columns as variables
                        echo "Filename: $order"
                        if [ "$order" == "$(($point_start+$run))" ]; then
                                                        
                            tail -n +2 "$info_2" | while IFS=, read -r filename2 xmin2 xmax2 ymin2 ymax2 index_2
                            do
                                # Use the columns as variables
                                echo "Filename: $filename2"
                                if [ "$index_2" == "$lon_index" ]; then

                                    tail -n +2 "$info_3" | while IFS=, read -r filename3 xmin3 xmax3 ymin3 ymax3 index_3
                                    do
                                        # Use the columns as variables
                                        echo "Filename: $filename3"
                                        if [ "$index_3" == "$index_2" ]; then
                                            # determine ctl path
                                            FILE_PATH="$MASTER_FOLDER/$run_folder/comcot.ctl"
            	                            CURRENT_SOURCE=$(sed -n '40p' "$FILE_PATH" | awk -F ': ' '{print $2}')
            	                            
                                            CURRENT_LAYER2_NAME=$(sed -n '99p' "$FILE_PATH" | awk -F ': ' '{print $2}')
                	                        CURRENT_LAYER2_XS=$(sed -n '95p' "$FILE_PATH" | awk -F ': ' '{print $2}')
                	                        CURRENT_LAYER2_XE=$(sed -n '96p' "$FILE_PATH" | awk -F ': ' '{print $2}')
                	                        CURRENT_LAYER2_YS=$(sed -n '97p' "$FILE_PATH" | awk -F ': ' '{print $2}')
            	                            CURRENT_LAYER2_YE=$(sed -n '98p' "$FILE_PATH" | awk -F ': ' '{print $2}')
            	                            
                                            CURRENT_LAYER3_NAME=$(sed -n '119p' "$FILE_PATH" | awk -F ': ' '{print $2}')
            	                            CURRENT_LAYER3_XS=$(sed -n '115p' "$FILE_PATH" | awk -F ': ' '{print $2}')
            	                            CURRENT_LAYER3_XE=$(sed -n '116p' "$FILE_PATH" | awk -F ': ' '{print $2}')
            	                            CURRENT_LAYER3_YS=$(sed -n '117p' "$FILE_PATH" | awk -F ': ' '{print $2}')
            	                            CURRENT_LAYER3_YE=$(sed -n '118p' "$FILE_PATH" | awk -F ': ' '{print $2}')
            	                            
                                            #determine new input of ctl
                                            source_name="$(pad $region 2)${mechanism}$(pad $(($point_start+$run)) 4)$(pad $depth 2)$(pad $magnitude 2).txt"
		                                    echo "Generated file name: $source_name"
            	                            NS_PATH="${MASTER_FOLDER}/Source_txt_generator/${source_name}"

                                            LAYER2_NAME_PATH="${MASTER_FOLDER}/batim/layer_2/${filename2}"
                	                        LAYER2_XS_PATH="$xmin2"
                	                        LAYER2_XE_PATH="xmax2"
                                            LAYER2_YS_PATH="$ymin2"
                                            LAYER2_YE_PATH="$ymax2"
            	                            
                                            LAYER3_NAME_PATH="${MASTER_FOLDER}/batim/layer_3/${filename3}"
        	                                LAYER3_XS_PATH="$xmin3"
        	                                LAYER3_XE_PATH="$xmax3"            	                                
                                            LAYER3_YS_PATH="$ymin3"
            	                            LAYER3_YE_PATH="$ymax3"
            	                            
                                            #change the input
                                            sed -i "40s|${CURRENT_SOURCE}|${NS_PATH}|" "$FILE_PATH"
            	                            
                                            sed -i "99s|${CURRENT_LAYER2_NAME}|${LAYER2_NAME_PATH}.asc|" "$FILE_PATH"
                	                        sed -i "95s|${CURRENT_LAYER2_XS}|${xmin2}|" "$FILE_PATH"
                	                        sed -i "96s|${CURRENT_LAYER2_XE}|${xmax2}|" "$FILE_PATH"
                	                        sed -i "97s|${CURRENT_LAYER2_YS}|${ymin2}|" "$FILE_PATH"
            	                            sed -i "98s|${CURRENT_LAYER2_YE}|${ymax2}|" "$FILE_PATH"
            	                            
                                            sed -i "119s|${CURRENT_LAYER3_NAME}|${LAYER3_NAME_PATH}.asc|" "$FILE_PATH"
            	                            sed -i "115s|${CURRENT_LAYER3_XS}|${xmin3}|" "$FILE_PATH"
                                            sed -i "116s|${CURRENT_LAYER3_XE}|${xmax3}|" "$FILE_PATH"
        	                                sed -i "117s|${CURRENT_LAYER3_YS}|${ymin3}|" "$FILE_PATH"
        	                                sed -i "118s|${CURRENT_LAYER3_YE}|${ymax3}|" "$FILE_PATH"
            	                            
                                            sed -n '40p' "$FILE_PATH"

                                            sed -n '99p' "$FILE_PATH"
                                            sed -n '95p' "$FILE_PATH"
                                            sed -n '96p' "$FILE_PATH"
                                            sed -n '97p' "$FILE_PATH"
                                            sed -n '98p' "$FILE_PATH"

                                            sed -n '119p' "$FILE_PATH"
                                            sed -n '115p' "$FILE_PATH"
                                            sed -n '116p' "$FILE_PATH"
                                            sed -n '117p' "$FILE_PATH"
                                            sed -n '118p' "$FILE_PATH"

                                            #run comcot            	    
            	                            export OMP_NUM_THREADS=48
            	                            ulimit -s unlimited
            	                            ./comcot

                                            #post processing
            	                            if [ $? -eq 0 ]; then
                	    	                    python3 export_asc_nc_ver1.py
                	    	                    echo "Exporting .asc file and .nc file has done"
                	    	                    echo "_________________________________________"
                	    	                    echo "Processing process_coastal_data.py"
                	    	                    #python3 process_coastal_data.py
            	    	
                	                        fi
                                            break
                                        fi
                                    done
                                    break          
                                fi    
                            done
                            break
                        fi    
                    done
            	fi
            ) &
            done
            wait
            point_start=$((point_start+5))  
        done
    done
done
