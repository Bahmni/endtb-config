update global_property set property_value = ('select ppa.value_reference as identifier,concat(pn.given_name,'' '', pn.family_name) as name,prog.name as Treatment, p.gender as gender,floor(datediff(now(), p.birthdate)/365) as age,concat("",p.uuid) as uuid, pi.identifier as "EMR ID"
from patient_program pp
  inner join program prog on pp.program_id = prog.program_id
  inner join patient_program_attribute ppa on pp.patient_program_id = ppa.patient_program_id
  inner join program_attribute_type pat on ppa.attribute_type_id = pat.program_attribute_type_id
  inner join person_name pn on pp.patient_id = pn.person_id
  inner join person p on p.person_id = pn.person_id
  inner join patient_identifier pi on pn.person_id = pi.patient_id
where pat.name = ''Registration Number'' and p.voided = 0 and pn.voided = 0 and prog.retired=0 and pp.voided = 0') where property = "emrapi.sqlSearch.allPatients";

