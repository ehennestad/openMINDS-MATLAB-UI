classdef (Abstract) ControlledTerm < openminds.abstract.Schema & openminds.category.Keyword

    properties (Access = private)
        Required_ = {'name'}
    end

    properties
        % Enter one sentence for defining this term.
        definition (1,1) string

        % Enter a short text describing this term.
        description (1,1) string

        % Enter the internationalized resource identifier (IRI) pointing to the integrated ontology entry in the InterLex project.
        interlexIdentifier (1,1) string

        % Enter the internationalized resource identifier (IRI) pointing to the wiki page of the corresponding term in the KnowledgeSpace.
        knowledgeSpaceLink (1,1) string

        % Controlled term originating from a defined terminology.
        name (1,1) string

        % Enter the internationalized resource identifier (IRI) pointing to the preferred ontological term.
        preferredOntologyIdentifier (1,1) string

        % Enter one or several synonyms (inlcuding abbreviations) for this controlled term.
        synonym (1,:) string {mustBeListOfUniqueItems(synonym)}
    end
       
    properties (Constant, Hidden)
        LINKED_PROPERTIES = struct()
        EMBEDDED_PROPERTIES = struct()
    end

    methods
        function obj = ControlledTerm()

        end
    end

    methods
        function str = char(obj)
            str = char(string(obj));
        end
    end

    methods (Static)
        function members = getMembers()
            className = mfilename('class');
            [~, members] = enumeration(className);
        end
    end

end