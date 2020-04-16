/**********************************************************************
 * Copyright 2019 Consultingwerk Ltd.                                 *
 *                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");    *
 * you may not use this file except in compliance with the License.   *
 * You may obtain a copy of the License at                            *
 *                                                                    *
 *     http://www.apache.org/licenses/LICENSE-2.0                     *
 *                                                                    *
 * Unless required by applicable law or agreed to in writing,         *
 * software distributed under the License is distributed on an        *
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,       *
 * either express or implied. See the License for the specific        *
 * language governing permissions and limitations under the License.  *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : start.p
    Purpose     :

    Syntax      :

    Description :

    Author(s)   : MikeFechner
    Created     : Wed Nov 27 06:10:19 CET 2019
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.PCT.AssembliesCatalog.* FROM PROPATH.
USING Consultingwerk.Studio.AssemblyParser.* FROM PROPATH.
USING Progress.Json.ObjectModel.*            FROM PROPATH.

//DEFINE INPUT  PARAMETER pcOutputFileName AS CHARACTER NO-UNDO.
DEFINE VARIABLE pcOutputFileName AS CHARACTER NO-UNDO INITIAL "c:\temp\assemblies.json":U .

DEFINE VARIABLE oParser  AS AssemblyParser    NO-UNDO .
DEFINE VARIABLE oCatalog AS AssembliesCatalog NO-UNDO .
DEFINE VARIABLE oJson    AS JsonArray         NO-UNDO .

{Consultingwerk/Studio/AssemblyParser/ttAssemblies.i}

/* ***************************  Main Block  *************************** */

oParser = NEW AssemblyParser() .
oParser:GetTable (OUTPUT TABLE ttAssemblies) .

IF NOT CAN-FIND (ttAssemblies WHERE ttAssemblies.AssemblyName = "mscorlib":U) THEN DO:
    CREATE ttAssemblies.
    ASSIGN ttAssemblies.AssemblyEntry  = "mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089":U
           ttAssemblies.AssemblyName   = "mscorlib":U
           ttAssemblies.Culture        = "neutral":U
           ttAssemblies.PublicKeyToken = "b77a5c561934e089":U
           ttAssemblies.Version        = "4.0.0.0":U .
END.

oJson = NEW JsonArray () .

oCatalog = NEW AssembliesCatalog() .

FOR EACH ttAssemblies:
    DISPLAY ttAssemblies.AssemblyEntry FORMAT "x(70)" WITH DOWN .
    PROCESS EVENTS .

    oCatalog:AddTypesFromAssembly (ttAssemblies.AssemblyEntry, oJson) .

    DOWN .
    PAUSE 0 BEFORE-HIDE .
END.

oJson:WriteFile (pcOutputFileName, TRUE) .
