/****************************************************************************
** $HQL_BEGIN_LICENSE$
**
** Copyright (C) 2020 by Luigi Ferraris
**
** This file is part of HQL project
**
** HQL is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** HQL is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with HQL.  If not, see <http://www.gnu.org/licenses/>.
**
** $HQL_END_LICENSE$
****************************************************************************/
#include "hqlinclude.ch"

/*!

 \brief starting procedure

*/
INIT PROCEDURE ThisInit()

   hb_CdpSelect( hb_CdpOS() )    // to align HVM to os codePage
   hb_SetTermCP( hb_CdpTerm() )  //where <cTermCP> is OS encoding and <cHostCP> is HVM encoding. When <cHostCP> is not given then _SET_CODEPAGE is used
   SET( _SET_OSCODEPAGE, hb_CdpOS() )
   SET( _SET_DBCODEPAGE, "ITWIN" )        // I choose Italian

   SET( _SET_EPOCH, 2000 )
   SET CENTURY ON
   SET( _SET_EXCLUSIVE, .F. )
   SET( _SET_DELETED, .F. )

RETURN

/*!

 \brief ending procedure

*/
EXIT PROCEDURE ThisExit()

   DBCOMMITALL()
   DBCLOSEALL()

RETURN

/*

   standard main procedure

*/
PROCEDURE Main()

   hqlErrorSys()  /*hbqt_errorsys()*/

   hqlSetStyle( "Fusion" )

   hqlOnAboutToQuit( { || UDFOnAboutToQuit() } )

   hqlStart()

   UDFshowMainWindow()

RETURN

STATIC PROCEDURE UDFOnAboutToQuit()
   hql_Trace( PADR("Quitting QApplication", 25) + hb_TtoS(hb_DateTime()) )
RETURN

/*!

 \brief show mainwindow

*/
STATIC PROCEDURE UDFshowMainWindow()
   LOCAL oWnd, oSize

   WITH OBJECT oWnd := hqlMainWindow(/*name*/)
      :setWindowTitle( "HQLPROGRESSBAR tester" )
      :setWindowIcon( QIcon( ":/hqlres/HQL96" ) )
      :setCentralWidget( hqlWidget(/*name*/) )
      :centralWidget():setLayout( hqlVBoxLayout() )

      WITH OBJECT hqlMenuBar(/*name*/)
         WITH OBJECT :hqlAddMenu(/*name*/)
            :hqlCaption( "&File" ) //==>:setTitle( "&File" )
            WITH OBJECT :hqlAddAction(/*name*/)
               :hqlCaption( "&Quit" )  //==>:setText( "&Quit" )
               :setIcon( QIcon( ":/hqlres/quit" ) )
               :setShortcut( QKeySequence( "Alt+Q" ) )
               :hqlOnTriggered( { || oWnd:hqlRelease() } )
            END WITH
            :addSeparator()
            WITH OBJECT :hqlAddAction(/*name*/)
               :hqlCaption( "&Close all windows" )
               :hqlOnTriggered( { || hqlQapplication:closeAllWindows() } )
               :setIcon( QIcon( ":/hqlres/exit" ) )
            END WITH
         END WITH

         WITH OBJECT :hqlAddMenu(/*name*/)
            :hqlCaption( "&Tools" )
            WITH OBJECT :hqlAddAction( /*name*/ )
               :hqlCaption( "&Start" )
               :hqlOnTriggered( { || UDFstart( oWnd ) } )
               :setShortcut( QKeySequence( "Alt+S" ) )
            END WITH
            WITH OBJECT :hqlAddAction(/*name*/)
               :hqlCaption( "&Reset" )
               :hqlOnTriggered( { || UDFreset(oWnd) } )
               :setShortcut( QKeySequence( "Alt+R" ) )
            END WITH

            :addSeparator()

            WITH OBJECT :hqlAddMenu( /*name*/ )
               :hqlCaption( "bar &1" )
               WITH OBJECT :hqlAddAction( /*name*/ )
                  :hqlCaption( "&Current is" )
                  :hqlOnTriggered( { || hql_MsgStop( "is="+hb_NtoC(oWnd:bar1:hqlValue()) ) } )
               END WITH
               WITH OBJECT :hqlAddAction( /*name*/ )
                  :hqlCaption( "&Set 50" )
                  :hqlOnTriggered( { || oWnd:bar1:hqlValue(50) } )
               END WITH
            END WITH

            WITH OBJECT :hqlAddMenu( /*name*/ )
               :hqlCaption( "bar &2" )
               WITH OBJECT :hqlAddAction( /*name*/ )
                  :hqlCaption( "&Current is" )
                  :hqlOnTriggered( { || hql_MsgStop( "is="+hb_NtoC(oWnd:bar2:hqlValue()) ) } )
               END WITH
               WITH OBJECT :hqlAddAction( /*name*/ )
                  :hqlCaption( "&Set 50" )
                  :hqlOnTriggered( { || oWnd:bar2:hqlValue(50) } )
               END WITH
            END WITH

         END WITH

      END WITH
   END WITH

   WITH OBJECT oWnd:centralWidget()

      WITH OBJECT hqlProgressBar( "bar1" )
         :move( 60, 10 )
         :resize( 400, 40 )
         :setRange( 0, 100 )
         :hqlOnValueChanged( { |nI, oSelf| UDFchgValue( nI, oSelf ) } )
      END WITH

      WITH OBJECT hqlProgressBar( "bar2" )
         :move( 10, 60 )
         :resize( 40, 400 )
         :setRange( 0, 100 )
         :setOrientation(  Qt_Vertical )
         :hqlOnValueChanged( { |nI, oSelf| UDFchgValue( nI, oSelf ) } )
      END WITH

   END WITH

   // trick to resize window at 90% of desktop
   oSize := HqlQDesktop:availableGeometry():size()
   oSize := QSize( oSize:width()*0.9, oSize:height()*0.9 )
   oWnd:resize( oSize )

   oWnd:hqlActivate()

RETURN

STATIC PROCEDURE UDFchgValue( nI, oSlider )
   hql_Trace( PADR("OnValueChanged: ",25) + "bar name=" + oSlider:objectName() + " its value =" + hb_NtoC( nI ) )
RETURN

STATIC PROCEDURE UDFstart( oWnd )

   LOCAL nI

   UDFreset( oWnd )

   FOR nI := oWnd:bar1:minimum() TO  oWnd:bar1:maximum()
      oWnd:bar1:setValue( nI )
   NEXT nI

   FOR nI := oWnd:bar2:minimum() TO  oWnd:bar2:maximum()
      oWnd:bar2:setValue( nI )
   NEXT nI

RETURN

STATIC PROCEDURE UDFreset( oWnd )

   oWnd:bar1:reset()
   oWnd:bar2:reset()

RETURN