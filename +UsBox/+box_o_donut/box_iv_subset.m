function valid_combos = box_iv_subset(IV, primary_combos, secondary_combos);
%limit the trials of a box_of_donut to the peak IV value (user specifed)


valid_combos = primary_combos & secondary_combos;


tic


