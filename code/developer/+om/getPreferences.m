function prefs = getPreferences(prefName)
    prefs = om.internal.Preferences.getSingleton();
    if nargin
        prefs = prefs.(prefName);
    end
end