#############################################################################
##
#W  field.gi                    GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains generic methods for division rings.
##
Revision.field_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  DivisionRingByGenerators( <gens> )  . . . . . . . . . .  for a collection
#M  DivisionRingByGenerators( <F>, <gens> )   . . for div.ring and collection
##
InstallOtherMethod( DivisionRingByGenerators,
    "method for a collection",
    true,
    [ IsCollection ], 0,
    coll -> FieldByGenerators(
        FieldOverItselfByGenerators( [ One( Representative( coll ) ) ] ),
        coll ) );

InstallMethod( DivisionRingByGenerators,
    "method for a field and a collection",
    IsIdentical,
    [ IsDivisionRing, IsCollection ] , 0,
    function( F, gens )
    local D;
    D:= Objectify( NewKind( FamilyObj( gens ),
                            IsField and IsAttributeStoringRep ),
                   rec() );
    SetLeftActingDomain( D, F );
    SetGeneratorsOfDivisionRing( D, AsList( gens ) );
    return D;
    end );


#############################################################################
##
#M  FieldOverItselfByGenerators( <gens> )
##
InstallMethod( FieldOverItselfByGenerators,
    true,
    [ IsCollection ], 0,
    function( gens )
    local F;
    if IsEmpty( gens ) then
      Error( "need at least one element" );
    fi;
    F:= Objectify( NewKind( FamilyObj( gens ),
                            IsField and IsAttributeStoringRep ),
                   rec() );
    SetLeftActingDomain( F, F );
    SetGeneratorsOfDivisionRing( F, gens );
    return F;
    end );


#############################################################################
##
#M  DefaultFieldByGenerators( <gens> )  . . . . . . . . . .  for a collection
##
InstallMethod( DefaultFieldByGenerators,
    "method for a collection",
    true,
    [ IsCollection ], 0,
    DivisionRingByGenerators );


#############################################################################
##
#F  Field( <z>, ... ) . . . . . . . . . field generated by a list of elements
#F  Field( [ <z>, ... ] )
#F  Field( <F>, [ <z>, ... ] )
##
Field := function ( arg )
    local   F;          # field containing the elements of <arg>, result

    # special case for one square matrix
    if    Length(arg) = 1
        and IsMatrix( arg[1] ) and Length( arg[1] ) = Length( arg[1][1] )
    then
        F := FieldByGenerators( arg );

    # special case for list of elements
    elif Length(arg) = 1  and IsList(arg[1])  then
        F := FieldByGenerators( arg[1] );

    # special case for subfield and generators
    elif Length(arg) = 2  and IsField(arg[1])  then
        F := FieldByGenerators( arg[1], arg[2] );

    # other cases
    else
        F := FieldByGenerators( arg );
    fi;

    # return the field
    return F;
end;


#############################################################################
##
#F  DefaultField( <z>, ... )  . . . . . default field containing a collection
##
DefaultField := function ( arg )
    local   F;          # field containing the elements of <arg>, result

    # special case for one square matrix
    if    Length(arg) = 1
        and IsMatrix( arg[1] ) and Length( arg[1] ) = Length( arg[1][1] )
    then
        F := DefaultFieldByGenerators( arg );

    # special case for list of elements
    elif Length(arg) = 1  and IsList(arg[1])  then
        F := DefaultFieldByGenerators( arg[1] );

    # other cases
    else
        F := DefaultFieldByGenerators( arg );
    fi;

    # return the default field
    return F;
end;


#############################################################################
##
#F  Subfield( <F>, <gens> ) . . . . . . . subfield of <F> generated by <gens>
#F  SubfieldNC( <F>, <gens> )
##
Subfield := function( F, gens )
    local S;
    if IsEmpty( gens ) then
      return PrimeField( F );
    elif     IsHomogeneousList( gens )
         and IsIdentical( ElementsFamily( FamilyObj(F) ), FamilyObj( gens ) )
         and ForAll( gens, g -> g in F ) then
      S:= FieldByGenerators( LeftActingDomain( F ), gens );
      SetParent( S, F );
      return S;
    fi;
    Error( "<gens> must be a list of elements in <F>" );
end;

SubfieldNC := function( F, gens )
    local S;
    if IsEmpty( gens ) then
      S:= Objectify( NewKind( FamilyObj( F ),
                              IsDivisionRing and IsAttributeStoringRep ),
                     rec() );
      SetLeftActingDomain( S, F );
      SetGeneratorsOfDivisionRing( S, AsList( gens ) );
    else
      S:= DivisionRingByGenerators( LeftActingDomain( F ), gens );
    fi;
    SetParent( S, F );
    return S;
end;


#############################################################################
##
#M  PrintObj( <F> ) . . . . . . . . . . . . . . . . . . . . . . print a field
##
InstallMethod( PrintObj, true, [ IsField and HasGeneratorsOfField ], 0,
    function( F )
    if IsPrimeField( LeftActingDomain( F ) ) then
      Print( "Field( ", GeneratorsOfField( F ), " )" );
    elif F = LeftActingDomain( F ) then
      Print( "FieldOverItselfByGenerators( ",
             GeneratorsOfField( F ), " )" );
    else
      Print( "AsField( ", LeftActingDomain( F ),
             ", Field( ", GeneratorsOfField( F ), " ) )" );
    fi;
    end );

InstallMethod( PrintObj, true, [ IsField ], 0,
    function( F )
    if IsPrimeField( LeftActingDomain( F ) ) then
      Print( "Field( ... )" );
    elif F = LeftActingDomain( F ) then
      Print( "AsField( ~, ... )" );
    else
      Print( "AsField( ", LeftActingDomain( F ), ", ... )" );
    fi;
    end );


#############################################################################
##
#M  IsPrimeField( <F> ) . . . . . . . . . . . . . . . . . for a division ring
##
InstallMethod( IsPrimeField,
    "method for a division ring",
    true,
    [ IsDivisionRing ], 0,
    F -> DegreeOverPrimeField( F ) = 1 );


#############################################################################
##
#M  IsNumberField( <F> )  . . . . . . . . . . . . . . . . . . . . for a field
##
InstallMethod( IsNumberField,
    "method for a field",
    true,
    [ IsField ], 0,
    F -> Characteristic( F ) = 0 and IsInt( DegreeOverPrimeField( F ) ) );


#############################################################################
##
#M  IsAbelianNumberField( <F> ) . . . . . . . . . . . . . . . . . for a field
##
InstallMethod( IsAbelianNumberField,
    "method for a field",
    true,
    [ IsField ], 0,
    F -> IsNumberField( F ) and IsCommutative( GaloisGroup(
                                         AsField( PrimeField( F ), F ) ) ) );


#############################################################################
##
#M  IsCyclotomicField( <F> )  . . . . . . . . . . . . . . . . . . for a field
##
InstallMethod( IsCyclotomicField,
    "method for a field",
    true,
    [ IsField ], 0,
    F ->     IsAbelianNumberField( F )
         and Conductor( F ) = DegreeOverPrimeField( F ) );


#############################################################################
##
#M  IsNormalBasis( <B> )  . . . . . . . . . . . . .  for a basis (of a field)
##
InstallMethod( IsNormalBasis,
    "method for a basis of a field",
    true,
    [ IsBasis ], 0,
    function( B )
    local vectors;
    if not IsField( UnderlyingLeftModule( B ) ) then
      Error( "<B> must be a basis of a field" );
    fi;
    vectors:= BasisVectors( B );
    return Set( vectors )
           = Set( Conjugates( UnderlyingLeftModule( B ), vectors[1] ) );
    end );


#############################################################################
##
#M  GeneratorsOfDivisionRing( <F> ) . . . . . . . . . . . . for a prime field
##
InstallMethod( GeneratorsOfDivisionRing,
    "method for a prime field",
    true,
    [ IsField and IsPrimeField ], 0,
    F -> [ One( F ) ] );


#############################################################################
##
#M  DegreeOverPrimeField( <F> ) . . . . . . . . . . . . . . for a prime field
##
InstallImmediateMethod( DegreeOverPrimeField, IsPrimeField, 20, F -> 1 );


#############################################################################
##
#M  NormalBase( <F> ) . . . . . . . . . .  for a field in characteristic zero
##
##  (uses the algorithm given in E. Artin, Galoissche Theorie, p. 65 f.).
##
InstallMethod( NormalBase,
    "method for a field in characteristic zero",
    true,
    [ IsField ], 0,
    function( F )

    local alpha, poly, normal, i, val;

    if Characteristic( F ) <> 0 then
      TryNextMethod();
    fi;

    # get a primitive element 'alpha'
    alpha:= PrimitiveElement( F );

    # the polynomial
    # $\prod_{\sigma\in 'Gal( alpha )'\setminus \{1\} } (x-\sigma('alpha') )
    # for the primitive element 'alpha'
    poly:= [ 1 ];
    for i in Difference( Conjugates( F, alpha ), [ alpha ] ) do
      poly:= ProductPol( poly, [ -i, 1 ] );
#T ?
    od;

    # for the denominator, eval 'poly' at 'a'
    val:= Inverse( ValuePol( poly, alpha ) );

    # there are only finitely many values 'x' in the subfield for which
    # 'poly(x) \* val' is not an element of a normal base.
    i:= 1;
    repeat
      normal:= Conjugates( F, ValuePol( poly, i ) * val );
      i:= i + 1;
    until RankMat( List( normal, COEFFSCYC ) ) = Dimension( F );

    return normal;
    end );


#############################################################################
##
#M  PrimitiveElement( <D> ) . . . . . . . . . . . . . . . for a division ring
##
InstallMethod( PrimitiveElement,
    "method for a division ring",
    true,
    [ IsDivisionRing ], 0,
    function( D )
    D:= GeneratorsOfDivisionRing( D );
    if Length( D ) = 1 then
      return D[1];
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Representative( <D> ) . . . . . for a division ring with known generators
##
InstallMethod( Representative,
    "method for a division ring with known generators",
    true,
    [ IsDivisionRing and HasGeneratorsOfDivisionRing ], 0,
    RepresentativeFromGenerators( GeneratorsOfDivisionRing ) );


#############################################################################
##
#M  GeneratorsOfRing( <F> ) . . . . . . .  ring generators of a division ring
##
InstallMethod( GeneratorsOfRing,
    "method for a division ring with known generators",
    true,
    [ IsDivisionRing and HasGeneratorsOfDivisionRing ], 0,
    F -> Concatenation( GeneratorsOfDivisionRing( F ),
                        [ One( F ) ],
                        List( GeneratorsOfDivisionRing( F ), Inverse ) ) );


#############################################################################
##
#M  GeneratorsOfUnitalRing( <F> ) . unital ring generators of a division ring
##
InstallMethod( GeneratorsOfUnitalRing,
    "method for a division ring with known generators",
    true,
    [ IsDivisionRing and HasGeneratorsOfDivisionRing ], 0,
    F -> Concatenation( GeneratorsOfDivisionRing( F ),
                        List( GeneratorsOfDivisionRing( F ), Inverse ) ) );


#############################################################################
##
#M  Enumerator( <F> ) . . . . . . . . . .  elements of a (finite) prime field
#M  EnumeratorSorted( <F> ) . . . . . . .  elements of a (finite) prime field
##
##  We install a special method only for prime fields,
##  since the other cases are handled by the vector space methods.
##
EnumeratorOfPrimeField := function( F )
    local one;
    if not IsFinite( F ) then
      Error( "sorry, cannot compute elements list of infinite field <F>" );
    fi;
    one:= One( F );
    return AsListSortedList( List( [ 0 .. Size( F ) - 1 ], i -> i * one ) );
end;

InstallMethod( Enumerator,
    "method for a prime field",
    true,
    [ IsField and IsPrimeField ], 0,
    EnumeratorOfPrimeField );

InstallMethod( AsList,
    "method for a prime field",
    true,
    [ IsField and IsPrimeField ], 0,
    EnumeratorOfPrimeField );


#T InstallMethod( EnumeratorSorted, true, [ IsField and IsPrimeField ], 0,
#T     EnumeratorOfPrimeField );
#T 
#T InstallMethod( AsListSorted, true, [ IsField and IsPrimeField ], 0,
#T     EnumeratorOfPrimeField );


#############################################################################
##
#M  \=( <F>, <G> ) . . . . . . . . . . . . . . . . . .  comparisons of fields
##
InstallMethod( \=,
    "method for two fields",
    IsIdentical,
    [ IsField, IsField ], 0,
    function ( F, G )

    if IsFinite( F ) and IsFinite( G ) then
      return     ( Size( F ) = Size( G ) )
             and ForAll( GeneratorsOfField( F ), g -> g in G );
    else
      return     ForAll( GeneratorsOfField( F ), g -> g in G )
             and ForAll( GeneratorsOfField( G ), g -> g in F );
    fi;
    end );


#############################################################################
##
#M  IsSubset( <F>, <G> )
##
InstallMethod( IsSubset,
    "method for two fields",
    IsIdentical,
    [ IsField, IsField ], 0,
    function ( F, G )

    if IsFinite( F ) and IsFinite( G ) then
      return     Size( F ) mod Size( G ) = 0
             and (Size( F ) - 1) mod (Size( G ) - 1) = 0
             and ForAll( GeneratorsOfField( G ), g -> g in F );
    else
      return ForAll( GeneratorsOfField( G ), g -> g in F );
    fi;
    end );

InstallMethod( IsSubset,
    "method for two fields",
    IsIdentical,
    [ IsDivisionRing, IsDivisionRing ], 0,
    function( D, F )
    return IsSubset( D, GeneratorsOfDivisionRing( F ) );
    end );


#############################################################################
##
#M  AsDivisionRing( <F>, <D> )
##
InstallMethod( AsDivisionRing,
    "method for two fields",
    IsIdentical,
    [ IsDivisionRing, IsDivisionRing ], 0,
    function( F, D )
    local E;

    if not IsSubset( D, F ) then
      Error( "<F> must be contained in <D>" );
    fi;

    E:= DivisionRingByGenerators( F, GeneratorsOfDivisionRing( D ) );

    RunIsomorphismImplications( D, E );
    RunSubsetImplications( D, E );

    return E;
    end );


#############################################################################
##
#M  Conjugates( <F>, <z> )  . . . . . . . . . . conjugates of a field element
#M  Conjugates( <z> )
##
InstallOtherMethod( Conjugates,
    "method for a scalar",
    true,
    [ IsScalar ], 0,
    z -> Conjugates( DefaultField( z ), z ) );

InstallMethod( Conjugates,
    "method for a field and a scalar",
    IsCollsElms,
    [ IsField, IsScalar ], 0,
    function ( F, z )
    local   cnjs,       # conjugates of <z> in <F>, result
            aut;        # automorphism of <F>

    # check the arguments
    if not z in F then Error( "<z> must lie in <F>" ); fi;

    # compute the conjugates simply by applying all the automorphisms
    cnjs := [];
    for aut in GaloisGroup( F ) do
        Add( cnjs, z ^ aut );
    od;

    # return the conjugates
    return cnjs;
    end );


#############################################################################
##
#M  Norm( <F>, <z> )  . . . . . . . . . . . . . . . . norm of a field element
#M  Norm( <z> )
##
InstallOtherMethod( Norm,
    "method for a scalar",
    true,
    [ IsScalar ], 0,
    z -> Norm( DefaultField( z ), z ) );

InstallMethod( Norm,
    "method for a field and a scalar",
    IsCollsElms,
    [ IsField, IsScalar ], 0,
    function ( F, z ) return Product( Conjugates( F, z ) ); end );


#############################################################################
##
#M  Trace( <F>, <z> ) . . . . . . . . . . . . . . .  trace of a field element
#M  Trace( <z> )
##
InstallOtherMethod( Trace,
    "method for a scalar",
    true,
    [ IsScalar ], 0,
    z -> Trace( DefaultField( z ), z ) );

InstallMethod( Trace,
    "method for a field and a scalar",
    IsCollsElms,
    [ IsField, IsScalar ], 0,
    function ( F, z ) return Sum( Conjugates( F, z ) ); end );


#############################################################################
##
#M  CharacteristicPolynomial( <F>, <z> )
##
InstallMethod( CharacteristicPolynomial,
    "method for a field and a scalar",
    IsCollsElms,
    [ IsField, IsScalar ], 0,
    MinimalPolynomial );


#############################################################################
##
##  Vector spaces of field elements are handled as follows.
##  Let $V$ be an $F$-space of field elements, and $K$ the (default) field of
##  the vector space generators of $V$.
##  It is assumed that methods for computing a basis $B$ for the
##  $F$-vector space $K$ are known;
##  e.g., one can compute a Lenstra basis of an abelian number field,
##  or take successive powers of a primitive root of a finite field.
##  For the vector space generators of $V$, choose a set of linearly
##  independent positions of the $B$-coefficients, and associate this sublist
##  of $B$-coefficients to every element of $V$.
##
##  Then computations can be performed using 'NiceFreeLeftModule',
##  'NiceVector', and 'UglyVector'.
##
##  Note that the situation here is a little bit different from that with
##  polynomials, since one has to compute the basis $B$ and the choice of
##  the positions first --this is done by 'NiceFreeLeftModule'-- and only
##  afterwards can use the 'NiceVector' and 'UglyVector'
##  functions.
##

#############################################################################
##
#R  IsFieldElementsSpaceRep( <V> )
##
##  is the representation of vector spaces of division ring elements
##  (that are themselves not division rings and)
##  that are handled via nice bases.
##  The associated basis is computed using a basis of the enveloping
##  division ring.
##
##  'fieldbasis' : \\
##     the canonical basis of the default field of the space generators
##     that is used to compute associated (row) vectors
##
##  'coeffschoice' : \\
##     list of positions in the coefficients list used to compute associated
##     nice (row) vectors
##
##  'canonicalvectors' : \\
##     list of vectors of <V> whose associated nice vectors are the canonical
##     basis vectors of the associated space.
##     They are the vectors of the canonical basis of <V>.
##
##  We have 'Coefficients( <V>!.fieldbasis, <x> ){ <V>!.coeffschoice }' the
##  associated nice vector of $x \in V$,
##  and '<r> \*\ <V>!.canonicalvectors' the associated vector of the row
##  vector <r>.
##
IsFieldElementsSpaceRep := NewRepresentation( "IsFieldElementsSpaceRep",
    IsHandledByNiceBasis,
    [ "fieldbasis", "coeffschoice", "canonicalvectors" ] );


#############################################################################
##
#M  PrepareNiceFreeLeftModule( <V> )
##
InstallMethod( PrepareNiceFreeLeftModule,
    "method for vector space of field elements",
    true,
    [ IsVectorSpace and IsFieldElementsSpaceRep ], 0,
    function( V )

    local gens,
          coeffs,
          sem;

    gens:= GeneratorsOfLeftModule( V );

    if IsEmpty( gens ) then

      V!.canonicalvectors := [];
      V!.coeffschoice:= [];

    else

      # Compute the default field of the space generators,
      # a basis of this field,
      # and the coefficients of the space generators w.r. to this basis.
      V!.fieldbasis:= BasisOfDomain( DefaultField( gens ) );
      coeffs:= List( gens, x -> Coefficients( V!.fieldbasis, x ) );

      # Choose a subset of linear independent positions,
      # and store field elements corresponding to the rows of the basis.
      # These are the vectors of the canonical basis of 'V'.
      sem:= SemiEchelonMatTransformation( coeffs );
      V!.canonicalvectors:= sem.coeffs * gens;

      coeffs:= sem.heads;
      V!.coeffschoice:= Filtered( [ 1 .. Length( coeffs ) ],
                                  x -> coeffs[x] <> 0 );

    fi;
    end );


#############################################################################
##
#M  NiceFreeLeftModule( <V> )
##
##  We do not use the default method since the nice space is known to be a
##  full row space.
##
InstallMethod( NiceFreeLeftModule,
    "method for vector space of field elements",
    true,
    [ IsFreeLeftModule and IsFieldElementsSpaceRep ], 0,
    function( V )
    PrepareNiceFreeLeftModule( V );
    return FullRowModule( LeftActingDomain( V ),
                          Length( V!.canonicalvectors ) );
    end );


#############################################################################
##
#M  NiceVector( <V>, <v> )
##
##  returns the row vector in 'NiceFreeLeftModule( <V> )' that corresponds
##  to the vector <v> of <V>.
##
InstallMethod( NiceVector,
    "method for field elements space and scalar",
    IsCollsElms,
    [ IsFreeLeftModule and IsFieldElementsSpaceRep, IsScalar ], 0,
    function( V, v )
    local c;
    c:= Coefficients( V!.fieldbasis, v );
    if c <> fail then
      c:= c{ V!.coeffschoice };
    fi;
    return c;
    end );


#############################################################################
##
#M  UglyVector( <V>, <r> )
##
##  returns the vector in <V> that corresponds to the vector <r> in
##  'NiceFreeLeftModule( <V> )'.
##
InstallMethod( UglyVector,
    "method for field elements space and row vector",
    IsIdentical,
    [ IsFreeLeftModule and IsFieldElementsSpaceRep, IsRowVector ], 0,
    function( V, r )
    if Length( r ) <> Length( V!.canonicalvectors ) then
      return fail;
    fi;
    return r * V!.canonicalvectors;
    end );


#############################################################################
##
#M  MutableBasisByGenerators( <R>, <gens> )
#M  MutableBasisByGenerators( <R>, <gens>, <zero> )
##
##  We choose a mutable basis that stores a mutable basis for a nice module.
##
InstallMethod( MutableBasisByGenerators,
    "method for field and collection of field elements",
    IsIdentical,
    [ IsField, IsCollection ], 0,
    MutableBasisViaNiceMutableBasisMethod2 );

InstallOtherMethod( MutableBasisByGenerators,
    "method for field, (possibly empty) list, and zero element",
    IsCollsXElms,
    [ IsField, IsList, IsScalar ], 0,
    MutableBasisViaNiceMutableBasisMethod3 );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <gens> ) . create vector space of field elms
##
InstallMethod( LeftModuleByGenerators,
    "method for division ring and collection of scalars in same family",
    IsIdentical,
    [ IsDivisionRing, IsScalarCollection ] , 0,
    function( F, gens )
    local V;
    V:= Objectify( NewKind( FamilyObj( gens ),
                                IsFreeLeftModule
                            and IsLeftActedOnByDivisionRing
                            and IsFieldElementsSpaceRep
                            and IsAttributeStoringRep ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( gens ) );
    return V;
    end );


#############################################################################
##
#F  LeftModuleByGenerators( <F>, <gens>, <zero> )
##
InstallOtherMethod( LeftModuleByGenerators,
    "method for division ring and collection of scalars in same family",
    IsCollsCollsElms,
    [ IsDivisionRing, IsScalarCollection, IsScalar ], 0,
    function( F, gens, zero )
    local V;
    V:= Objectify( NewKind( FamilyObj( F ),
                                IsFreeLeftModule
                            and IsLeftActedOnByDivisionRing
                            and IsFieldElementsSpaceRep
                            and IsAttributeStoringRep ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( gens ) );
    SetZero( V, zero );
    return V;
    end );


#############################################################################
##
#M  Quotient( <F>, <r>, <s> ) . . . . . . . . quotient of elements in a field
##
InstallMethod( Quotient,
    "method for field, and two ring elements",
    IsCollsElmsElms,
    [ IsField, IsRingElement, IsRingElement ], 0,
    function ( F, r, s )
    return r/s;
    end );


#############################################################################
##
#M  IsUnit( <F>, <r> )  . . . . . . . . . . check for being a unit in a field
##
InstallMethod( IsUnit,
    "method for field, and ring element",
    IsCollsElms,
    [ IsField, IsRingElement ], 0,
    function ( F, r )
    return not IsZero( r ) and r in F;
    end );


#############################################################################
##
#M  Units( <F> )
##
InstallMethod( Units,
    "method for a division ring",
    true,
    [ IsDivisionRing ], 0,
    function( D )
    if IsFinite( D ) then
      return Difference( AsList( D ), [ Zero( D ) ] );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsAssociated( <F>, <r>, <s> ) . . . . . . check associatedness in a field
##
InstallMethod( IsAssociated,
    "method for field, and two ring elements",
    IsCollsElmsElms,
    [ IsField, IsRingElement, IsRingElement ], 0,
    function ( F, r, s )
    return (r = Zero( F ) ) = (s = Zero( F ) );
    end );


#############################################################################
##
#M  StandardAssociate( <F>, <x> ) . . . . . . . standard associate in a field
##
InstallMethod( StandardAssociate,
    "method for field and ring element",
    IsCollsElms,
    [ IsField, IsScalar ], 0,
    function ( R, r )
    if r = Zero( R ) then
        return Zero( R );
    else
        return One( R );
    fi;
    end );


#############################################################################
##
##  Field homomorphisms
##

#############################################################################
##
#M  IsFieldHomomorphism( <map> )
##
InstallMethod( IsFieldHomomorphism,
    true,
    [ IsGeneralMapping ], 0,
    map -> IsRingHomomorphism( map ) and IsField( Source( map ) ) );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <fldhom> )  . .  for a field homomorphism
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "method for a field homomorphism",
    true,
    [ IsFieldHomomorphism ], 0,
    function ( hom )
    if ForAll( GeneratorsOfField( Source( hom ) ),
               x -> IsZero( ImageElm( hom, x ) ) ) then
      return Source( hom );
    else
      return [ Zero( Source( hom ) ) ];
    fi;
    end );


#############################################################################
##
#M  IsInjective( <fldhom> ) . . . . . . . . . . . .  for a field homomorphism
##
InstallMethod( IsInjective,
    "method for a field homomorphism",
    true,
    [ IsFieldHomomorphism ], 0,
    hom -> Size( KernelOfAdditiveGeneralMapping( hom ) ) = 1 );


#############################################################################
##
#M  IsSurjective( <fldhom> )  . . . . . . . . . . .  for a field homomorphism
##
InstallMethod( IsSurjective,
    "method for a field homomorphism",
    true,
    [ IsFieldHomomorphism ], 0,
    function ( hom )
    if IsFinite( Range( hom ) ) then
      return Size( Range( hom ) ) = Size( Image( hom ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  \=( <hom1>, <hom2> )  . . . . . . . . . comparison of field homomorphisms
##
InstallMethod( \=,
    "method for two field homomorphisms",
    IsIdentical,
    [ IsFieldHomomorphism, IsFieldHomomorphism ], 0,
    function ( hom1, hom2 )

    # maybe the properties we already know determine the result
    if ( HasIsInjective( hom1 ) and HasIsInjective( hom2 )
         and IsInjective( hom1 ) <> IsInjective( hom2 ) )
    or ( HasIsSurjective( hom1 ) and HasIsSurjective( hom2 )
         and IsSurjective( hom1 ) <> IsSurjective( hom2 ) ) then
        return false;

    # otherwise we must really test the equality
    else
        return Source( hom1 ) = Source( hom2 )
            and Range( hom1 ) = Range( hom2 )
            and ForAll( GeneratorsOfField( Source( hom1 ) ),
                   elm -> Image(hom1,elm) = Image(hom2,elm) );
    fi;
    end );


#############################################################################
##
#M  ImagesSet( <hom>, <elms> ) . . images of a set under a field homomorphism
##
InstallMethod( ImagesSet,
    "method for field homomorphism and field",
    CollFamSourceEqFamElms,
    [ IsFieldHomomorphism, IsField ], 0,
    function ( hom, elms )
    if IsSubset( Source( hom ), elms )  then
        return FieldByGenerators( List( GeneratorsOfField( elms ),
                                gen -> Image( hom, gen ) ) );
    else
        Error( "<elms> must be a subset of the source of <hom>" );
    fi;
    end );


#############################################################################
##
#M  PreImagesElm( <hom>, <elm> )  . . . . . . . . . . . .  preimage of an elm
##
InstallMethod( PreImagesElm,
    "method for field homomorphism and element",
    FamRangeEqFamElm,
    [ IsFieldHomomorphism, IsObject ], 0,
    function ( hom, elm )
    if IsInjective( hom ) = 1 then
      return [ PreImagesRepresentative( hom, elm ) ];
    elif IsZero( elm ) then
      return Source( hom );
    else
      return [];
    fi;
    end );


#############################################################################
##
#M  PreImagesSet( <hom>, <elm> )  . . . . . . . . . . . . . preimage of a set
##
InstallMethod( PreImagesSet,
    "method for field homomorphism and field",
    CollFamRangeEqFamElms,
    [ IsFieldHomomorphism, IsField ], 0,
    function ( hom, elms )
    if IsSubset( Range( hom ), elms )  then
      return FieldByGenerators( List( GeneratorsOfField( elms ),
                              gen -> PreImagesRepresentative( hom, gen ) ) );
    else
      Error( "<elms> must be a subset of the range of <hom>" );
    fi;
    end );


#############################################################################
##
#E  field.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



