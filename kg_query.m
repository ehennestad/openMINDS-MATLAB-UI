
% Get bearer token from the swagger api doc with ebrains login
% https://core.kg.ebrains.eu/swagger-ui/index.html?urls.primaryName=1%20advanced#/types/listTypes

bearerToken = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJfNkZVSHFaSDNIRmVhS0pEZDhXcUx6LWFlZ3kzYXFodVNJZ1RXaTA1U2k0In0.eyJleHAiOjE2NjY3ODM3NDcsImlhdCI6MTY2Njc4Mjg0NywiYXV0aF90aW1lIjoxNjY2NzczNTUzLCJqdGkiOiIyNmE4MzhiNC04MzdhLTQ0MDMtYjgwNC04ZjNmOTNkMjdhZDMiLCJpc3MiOiJodHRwczovL2lhbS5lYnJhaW5zLmV1L2F1dGgvcmVhbG1zL2hicCIsImF1ZCI6WyJqdXB5dGVyaHViIiwidHV0b3JpYWxPaWRjQXBpIiwieHdpa2kiLCJqdXB5dGVyaHViLWpzYyIsInRlYW0iLCJwbHVzIiwiZ3JvdXAiXSwic3ViIjoiODAwZjUzZTItMzc2Yi00MTA3LWE3OWMtNGFlNzgxMDkzZmI5IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoia2ciLCJzZXNzaW9uX3N0YXRlIjoiNTZiZTQyNzktYTNhYS00ZTM1LTgxZjYtMDQ5YjVjYTEyMjI1IiwiYWNyIjoiMCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgcm9sZXMgZW1haWwgZ3JvdXAgY2xiLndpa2kucmVhZCB0ZWFtIiwic2lkIjoiNTZiZTQyNzktYTNhYS00ZTM1LTgxZjYtMDQ5YjVjYTEyMjI1IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJFaXZpbmQgSGVubmVzdGFkIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiZWl2aW5kIiwiZ2l2ZW5fbmFtZSI6IkVpdmluZCIsImZhbWlseV9uYW1lIjoiSGVubmVzdGFkIiwiZW1haWwiOiJlaXZpbmQuaGVubmVzdGFkQG1lZGlzaW4udWlvLm5vIn0.yguW5tjCnhKL8iWNuFLTHuCCCcHd_461yD71Ig3WPL21W2j0kQUMcYqpTcdt6JnTmVBzaeX8SkoBK-PG2OVjveaJKoimjJ-MrWwevNm-5WgWiKC0bmFj1y1jJk4YlVqL9pYoEJm3fIGq4JVIW87xk4CUejID32eKvAf4W8EurRC_cF1qJPDzXg6pt6ky-VOmEZZVdUF60eKmYm-bBrmjlaeWYgpMkmlkk_QpLKyIRqRDGHrdkKVE081H1J_QjSm6Z6Ul1O1Qg-F2wvtnRrXaAG2Ov4yttiyrVZqqufJO56uDItRAg2iOLdgctGKsWwfTDUAp4yFVk0UMV9HD3Q_QOw';

apiQueryUrl = 'https://core.kg.ebrains.eu/v3-beta/types?stage=IN_PROGRESS&space=dataset&withProperties=true&withIncomingLinks=true';


webopts = weboptions();
webopts.HeaderFields = {'Authorization', bearerToken};

response = webread(apiQueryUrl, webopts);

s = utility.struct.structcat(1, response.data{:});
t = struct2table(s);

names = t.http___schema_org_name;
subjectStateRowIdx = find( strcmp(names, 'Subject state') );

subjectStateEntry = s(subjectStateRowIdx);
subjectStateEntry.https___core_kg_ebrains_eu_vocab_meta_properties{1}



for i = 1:size(t,1)
    fprintf('%s\n', t{i, 'http___schema_org_name'}{1})
    try
    struct2table(t{i, 'https___core_kg_ebrains_eu_vocab_meta_incomingLinks'}{1}, 'AsArray', true)
    catch
        disp('Failed')
    end
end


ssInLink = subjectStateEntry.https___core_kg_ebrains_eu_vocab_meta_incomingLinks;
ssInLink2 = ssInLink(2);
ttt = struct2table(ssInLink2.https___core_kg_ebrains_eu_vocab_meta_sourceTypes);

metaspaces = ttt.https___core_kg_ebrains_eu_vocab_meta_spaces
metaspaces{2}



ssInLink1 = ssInLink(1);
ttt = struct2table(ssInLink1.https___core_kg_ebrains_eu_vocab_meta_sourceTypes);

metaspaces = ttt.https___core_kg_ebrains_eu_vocab_meta_spaces
metaspaces{2}

ssInLink5 = ssInLink(5);
ttt = struct2table(ssInLink5.https___core_kg_ebrains_eu_vocab_meta_sourceTypes);

metaspaces = ttt.https___core_kg_ebrains_eu_vocab_meta_spaces
metaspaces{2}

% Check incoming links:
%   shows all properties (from other schemas) where the schema can be added.
%   each property item contains a list of the schemas that can be the  originator

