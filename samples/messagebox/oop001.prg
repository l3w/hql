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
   LOCAL oWnd, this, oSize
   LOCAL oVlayout

   WITH OBJECT oWnd := hqlMainWindow(/*name*/)
      this := :hqlThis()
      :setWindowTitle( "HQLMESSAGEBOX tester" )
      :setWindowIcon( QIcon( ":/hqlres/HQL96" ) )
      :setCentralWidget( hqlWidget(/*name*/, this) )
      :centralWidget:setLayout( hqlVBoxLayout(/*name*/) )
      :hqlSetFkey( Qt_Key_F9, Qt_ControlModifier, {|| hql_MsgStop( "works fine" ) } )
   END WITH

   oVlayout := oWnd:centralWidget():layout()
   WITH OBJECT oWnd:centralWidget()

      WITH OBJECT hqlLabel(/*name*/)
         :hqlAddMeToLayout( oVlayout )
         :hqlCaption( "press <CTRL>+F9 somewhere" )
      END WITH

      WITH OBJECT hqlPushButton(/*name*/)
         :hqlAddMeToLayout( oVlayout )
         :hqlCaption( "Exit" )
         :hqlOnClicked( { || oWnd:hqlRelease() } )
      END WITH

      WITH OBJECT hqlPushButton(/*name*/)
         :hqlAddMeToLayout( oVlayout )
         :hqlCaption( "hql_MsgInfo" )
         :hqlOnClicked( { || hql_Trace( "msgInfo ret:" + hb_NtoS(hql_MsgInfo( "the text", "the win title", "the detail", "the info text" )) ) } )
      END WITH

      WITH OBJECT hqlPushButton(/*name*/)
         :hqlAddMeToLayout( oVlayout )
         :hqlCaption( "hqlMsgStop" )
         :hqlOnClicked( { || hql_Trace( "msgStop ret:" + hb_NtoS(hql_MsgStop( "the text", "the win title", "the detail", "the info text" )) ) } )
      END WITH

      WITH OBJECT hqlPushButton(/*name*/)
         :hqlAddMeToLayout( oVlayout )
         :hqlCaption( "hql_MsgWarn" )
         :hqlOnClicked( { || hql_Trace( "msgWarn ret:" + hb_NtoS(hql_MsgWarn( "the text", "the win title", "the detail", "the info text" )) ) } )
      END WITH

      WITH OBJECT hqlPushButton(/*name*/)
         :hqlAddMeToLayout( oVlayout )
         :hqlCaption( "hql_MsgYesNo" )
         :hqlOnClicked( { || hql_Trace( "msgYesNo ret:" + hb_NtoS(hql_MsgYesNo( "the text", "the win title", "the detail", "the info text" )) ) } )
      END WITH

      WITH OBJECT hqlPushButton(/*name*/)
         :hqlAddMeToLayout( oVlayout )
         :hqlCaption( "Timed hqlMessageBox" )
         :hqlOnClicked( { || UDFshowTimedMessage() } )
      END WITH

      oVlayout:addStretch()   // pushup

   END WITH

   // trick to resize window at 90% of desktop
   oSize := HqlQDesktop:availableGeometry():size()
   oSize := QSize( oSize:width()*0.9, oSize:height()*0.9 )
   oWnd:resize( oSize )

   oWnd:hqlActivate()

RETURN

STATIC PROCEDURE UDFshowTimedMessage( oParent )
   LOCAL oWnd

   WITH OBJECT oWnd := hqlMessageBox(/*name*/, oParent )
      :hqlCaption( "window title" )
      :setWindowIcon( QIcon( ":/hqlres/dummy" ) )
      :setIcon( QMessageBox_Warning )
      :setText( "Timed message; disapper after 3000msec" )
      :hqlSetTimed( 3000, 99 )   // 99 exit code fo timeout
   END WITH

   hql_Trace( "timed message ret:" + hb_NtoS(oWnd:hqlActivate()) )

RETURN
