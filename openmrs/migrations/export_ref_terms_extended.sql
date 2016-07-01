select concept_source_id into @source_id from concept_reference_source where name = 'EndTB-Export';

insert into concept_reference_term (creator,code,concept_source_id,uuid,date_created) values
(4,'57',@source_id,uuid(),now()),
(4,'58',@source_id,uuid(),now()),
(4,'73',@source_id,uuid(),now()),
(4,'74',@source_id,uuid(),now()),
(4,'75',@source_id,uuid(),now()),
(4,'76',@source_id,uuid(),now()),
(4,'95',@source_id,uuid(),now());

