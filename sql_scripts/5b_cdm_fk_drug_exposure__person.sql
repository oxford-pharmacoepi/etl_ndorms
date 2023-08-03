ALTER TABLE drug_exposure ADD CONSTRAINT fpk_drug_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
