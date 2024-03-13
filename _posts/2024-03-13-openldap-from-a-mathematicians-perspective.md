---
layout: post
title: OpenLDAP from a Mathematician's perspective
---
{% include mathjax.html %}

# OpenLDAP from a Mathematician's perspective

[OpenLDAP](https://www.openldap.org/) is notorious for being a hard technology. There's an excellent [book by Zytrax on OpenLDAP](https://www.zytrax.com/books/ldap/), and of course the documentation of the OpenLDAP project, but I wish to supplement the above by giving an introduction from a Mathematician's perspective.

The description below is not complete nor comprehensive, but it serves to paint a broad picture of how the parts of LDAP work. Where it diverges is in the nitty-gritty details; for those, you will have to consult the aforementioned references.

## Attributes

An attribute is the key part of a [key-value](https://en.wikipedia.org/wiki/Name%E2%80%93value_pair) pair.

## Schemas

_Schemas_ ([schemata](https://en.wiktionary.org/wiki/schemata), properly) are [bipartite graphs](https://en.wikipedia.org/wiki/Bipartite_graph) on two sets of nodes: _object classes_ $\mathcal{O}$ and _attributes_ $\mathcal{A}$. The bipartite graph can be thought of as a function $s(o)\subseteq\mathcal{A}$ for $o\in\mathcal{O}$, which means that the object $o$ has been assigned the set of attributes denoted by $s(o)$.

Naturally then we can understand what a subschema is by borrowing from graph theory. The union of all loaded schemas is what the LDAP server has in memory at any point in time.

## Directory Information Trees

A _Directory Information Tree_ (DIT) is a [tree](https://en.wikipedia.org/wiki/Tree_(graph_theory)) (again borrowing from graph theory) with labeled nodes. The labels are called _Distinguished Names_ (DN.) They have the property that they're recursively defined so that each node label identifies its entire ancestry, exactly like a filesystem path identifiers all its ancestor directories.

Let's call that tree $\mathcal{D}$. There's an object class function $c : \mathcal{D} \to \mathcal{O}$ that assigns to each node a primary object class, with corresponding attributes (see schemas.) The content of the node is giving attributes values, i.e. a function $s(c(d)) \to \text{Data}$, where $d\in\mathcal{D}$ is a DN. However this assignment is not completely arbitrary: each attribute is defined to restrict its potentially assigned values, so an attribute can be thought of as a name and a type, and when an attribute is assigned a value, it must be of that particular type. To put it simply, an attribute called _Geolocation_ might be only assigned values of a pair of [latitude and longtitude](https://en.wikipedia.org/wiki/Geographic_coordinate_system).

DITs are defined in [LDIF](https://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format) files.

## Object Identifiers

[Object Identifiers](https://en.wikipedia.org/wiki/Object_identifier) (OIDs) are numerical tree names (like 3.14.151.9) together with descriptions of things. A standardized OID is published, and among other things, (OIDs are not restricted to LDAP concepts) it contains definitions and descriptions of object classes and attributes. There is room for private OIDs, so the OID tree can be extended by others (e.g. organizations like IBM, Microsoft, etc.)

The usefulness of OIDs is that I can assign an OID to the IPv4 address format, or the e-mail address format, etc, and then not have to worry about how software will implement this (of couse software implementors will have to worry about such details.) Then a particular attribute that requires an IPv4 address in its value can be defined by referencing the corresponding OID.

For example, here's the definition of [OID 2.5.4.41](https://www.alvestrand.no/objectid/2.5.4.41.html), the `name` attribute:

```
name ATTRIBUTE ::= {
	WITH SYNTAX DirectoryString {MAX}
	EQUALITY MATCH RULE caseIgnoreMatch
	SUBSTRINGS MATCHING RULE caseignoreSubstringsMatch
	ID {id-at-name}
}
```

This is [ASN.1](https://en.wikipedia.org/wiki/ASN.1) legalese; there's no code here, but if you keep following definitions, you will end up in algorithmic descriptions of things, e.g. `caseIgnoreMatch` (also described by an OID; see [2.5.13.2](https://www.alvestrand.no/objectid/2.5.13.2.html)) is just a case-ignoring string equality algorithm, which as you may note, is not concerning itself with [UTF-8](https://en.wikipedia.org/wiki/UTF-8) or whatnot; it's merely telling you descriptively that case should be ignored.

## Binding

Binding means to provide a DN in a DIT and a password that matches the content of the password attribute of the given DN. The LDAP server verifies the match and binds you to the DN.

## Configuration of OpenLDAP

There's a quirk of OpenLDAP, that its server configuration is also a DIT! ([When you have a hammer](https://en.wikipedia.org/wiki/Law_of_the_instrument)...)

## Conclusion

This is a high-level overview of what LDAP is, and hopefully it will make learning OpenLDAP easier for you! See also my [MediaWiki \+ OpenLDAP multi-container docker image](https://github.com/createyourpersonalaccount/openldap-mediawiki/) for a practical application of this: basically using the LDAP server for managing user accounts and login on the MediaWiki instance.

You will note that we do not write our own attributes or object classes in that project, we merely use existing ones to define our user database DIT (see [example.com.ldif](https://github.com/createyourpersonalaccount/openldap-mediawiki/blob/main/ldap/config/example.com.ldif).) This is fairly typical, not only because LDAP is old and there's a lot of work already done that we can leverage, but also because complexity increases by adding our own schemas.
