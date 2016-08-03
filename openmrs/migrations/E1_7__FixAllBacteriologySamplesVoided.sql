CREATE PROCEDURE fix_all_bacteriology_samples_voided()
  BEGIN
    DECLARE sample_obs_id INT DEFAULT 0;
    DECLARE no_more_rows BOOLEAN DEFAULT FALSE;
    DECLARE bacteriologySampleCursor CURSOR FOR SELECT obs_id FROM obs WHERE concept_id = 1187 and voided = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows = TRUE;
    OPEN bacteriologySampleCursor;
    fix_child_obs: LOOP
      FETCH bacteriologySampleCursor INTO sample_obs_id;
      IF no_more_rows
      THEN
        CLOSE bacteriologySampleCursor;
        LEAVE fix_child_obs;
      ELSE
        SET @child_obs = sample_obs_id;
        CALL get_all_child_obs(sample_obs_id,@child_obs);
        UPDATE obs SET voided = TRUE WHERE FIND_IN_SET(obs_id, @child_obs);
      END IF;
    END LOOP fix_child_obs;
  END;