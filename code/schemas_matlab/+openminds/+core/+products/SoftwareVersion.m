classdef SoftwareVersion < openminds.core.products.ResearchProductVersion

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/SoftwareVersion"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'applicationCategory', 'device', 'feature', 'language', 'license', 'operatingSystem', 'programmingLanguage'}
    end

    properties
        % Add all categories to which this software version belongs.
        applicationCategory (1,:) openminds.controlledTerms.SoftwareApplicationCategory

        % If necessary, add one or several developers (person or organization) that contributed to the code implementation of this software version. Note that these developers will overwrite the once provided in the software product this version belongs to.
        developer (1,:) {core.category.LegalPerson}

        % Add all hardware devices compatible with this software version.
        device (1,:) openminds.controlledTerms.OperatingDevice

        % Add the globally unique and persistent digital identifier of this research product version.
        digitalIdentifier (1,1) {openminds.core.DOI, openminds.core.SWHID}

        % Add all software versions that supplement this software version.
        hasComponent (1,:) openminds.core.SoftwareVersion

        % Add all distinguishing characteristics of this software version (e.g. performance, portability, or functionality).
        feature (1,:) openminds.controlledTerms.SoftwareFeature

        % Enter all requirements of this software version.
        requirement (1,:) string

        % Add the content types of all possible input formats for this software version.
        inputFormat (1,:) openminds.core.ContentType

        % Add all software versions that can be used alternatively to this software version.
        isAlternativeVersionOf (1,:) openminds.core.SoftwareVersion

        % Add the software version preceding this software version.
        isNewVersionOf (1,1) openminds.core.SoftwareVersion

        % Add all languages supported by this software version.
        language (1,:) openminds.controlledTerms.Language

        % Add at least one license for this software version.
        license (1,:) openminds.core.License

        % Add all operating systems supported by this software version.
        operatingSystem (1,:) openminds.controlledTerms.OperatingSystem

        % Add the content types of all possible input formats for this software version.
        outputFormat (1,:) openminds.core.ContentType

        % Add all programming languages used for this software version.
        programmingLanguage (1,:) openminds.controlledTerms.ProgrammingLanguage
    end

    methods
        function obj = SoftwareVersion()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end