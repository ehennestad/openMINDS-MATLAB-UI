% Dataset author heterogeneous list

ds = openminds.core.Dataset();

eh = openminds.core.actors.Person('givenName', 'Eivind', 'familyName', 'Hennestad');
lz = openminds.core.actors.Person('givenName', 'Lyuba', 'familyName', 'Zehl'); 
org = openminds.core.actors.Organization('fullName', 'University of Oslo', 'shortName', 'UIO');

ds.author = {eh, lz};
