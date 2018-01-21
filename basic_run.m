
file_loc='/home/juhani/Documents/cardio/c1161/111221/c1161m1.fif';
p=Preprocess(file_loc);
p.data.load({'fif'})
p.data.cur=p.data.raw;
p.qrs_trig(p.good_chn([1:100]));
p.find_bad_chn();
p.compute_ssp();
p.compute_baseline_spline(-400);
p.find_good_beats(p.data.qrs_triggers,-300,300,0.9);
p.compute_averages(-300,500);
p.data.save()

c=Choosing(file_loc);
c.load_qrs_avgs()
c.choose
c.save_borders

p=Preprocess(file_loc);
p.data.load({'cur','bad_chn','qrs_triggers','borders'});
p.p_trig()
p_rad=round((p.data.borders(2)-p.data.borders(1))/2);

p.find_good_beats(p.data.qrs_triggers+p.data.p_triggers,-round(p_rad),round(p_rad))

p.compute_p_averages(p.data.qrs_triggers+p.data.p_triggers)
p.data.save({'p_triggers','p_avgs','good_beats'})

