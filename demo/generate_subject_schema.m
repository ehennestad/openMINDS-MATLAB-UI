% Example of how to re-generate an individual schema

schemaTable = om.internal.dir.listSourceSchemas();

isSubject = strcmp(schemaTable.SchemaName, 'subject');

subjectSchemaFilepath = schemaTable.Filepath(isSubject);

om.generator.SchemaConverter( subjectSchemaFilepath, "reset" )
