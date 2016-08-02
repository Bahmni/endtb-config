ET max_sp_recursion_depth=255;

DROP PROCEDURE IF EXISTS get_all_child_obs;

CREATE PROCEDURE get_all_child_obs(parent_obs_id INT, INOUT child_Obs_ids VARCHAR(1024))

  BEGIN

    DECLARE temp_obs_id INT DEFAULT 0;

    DECLARE no_more_rows BOOLEAN DEFAULT FALSE;

    DECLARE childObsCursor CURSOR FOR SELECT obs_id FROM obs WHERE obs_group_id = parent_obs_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows = TRUE;

    OPEN childObsCursor;

    get_child: LOOP

      FETCH childObsCursor INTO temp_obs_id;

      IF no_more_rows

        THEN

        CLOSE childObsCursor;

        LEAVE get_child;

      ELSE

        SET child_Obs_ids = CONCAT(child_Obs_ids,',', temp_obs_id);

        CALL get_all_child_obs(temp_obs_id,child_Obs_ids);

      END IF;

    END LOOP get_child;

  END;
