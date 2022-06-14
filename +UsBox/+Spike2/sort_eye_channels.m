function sort_eye_channels(eye_pos,Triggers,max_trial_duration)


eye_pos.z = sqrt(eye_pos.x.^2 + eye_pos.y.^2);


%sort eye position data by trial

eye_pos.x_trial = EyePos.sort(eye_pos.x,eye_pos.t,Triggers,max_trial_duration);
eye_pos.y_trial = EyePos.sort(eye_pos.y,eye_pos.t,Triggers,max_trial_duration);
eye_pos.z_trial = EyePos.sort(eye_pos.z,eye_pos.t,Triggers,max_trial_duration);

eye_pos.x_trial = eye_pos.x_trial - nanmean(eye_pos.x_trial(:));
eye_pos.y_trial = eye_pos.y_trial - nanmean(eye_pos.y_trial(:));
eye_pos.z_trial =sqrt(eye_pos.x_trial.^2 + eye_pos.y_trial.^2);