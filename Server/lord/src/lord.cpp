/////////////////////////////////////////////////////////////////////////////
//  FileName    :   lord.cpp
//  Creator     :   zuolizhi
//  Date        :   2006-5-30 9:54:00
//  Comment     :   Function Routine Define
//	Changes		:	
/////////////////////////////////////////////////////////////////////////////
#include "ministerinterface.h"
#include "stdio.h"

#include <time.h>
/////////////////////////////////////////////////////////////////////////////
//
//              Global variables and Macro and Structure Definitions
//
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
//
//              Function Definitions
//
/////////////////////////////////////////////////////////////////////////////
#define MAX_INPUT_STRING 256
//#define MAX_WAIT_TIME	( 60 * 15 )

int main(int argc, char* argv[])
{
	
	IController*		pController = 0;

	if( INVALID_VALUE == CreateController( pController ) || !pController )
	{
		fprintf( stderr, "Unable to create game server controller.\n" );
		return 1;
	}

	int nDaemon = 0;

	if( argc > 1 && 
		argv[1][0] == '-' 
		&& argv[1][1] == 'd' )
		nDaemon = 1;

	if( INVALID_VALUE == pController->Startup( nDaemon ) )
	{
		fprintf( stderr, "Game server Startup failed.\n" );
		pController->Release( );
		return 1;
	}

	char szInput[MAX_INPUT_STRING] = {0};

	while( true )
	{
		unsigned long ulStop = time( 0 );

		if( nDaemon )
		{
			if( pController->IsStop( ) )
			{
				while( !pController->Ishalt( ) )
				{
// 					if( time( 0 ) - ulStop > MAX_WAIT_TIME )
// 						break;
					
					pController->yield( );
				}
				
				break;
			}
			else
				pController->yield( );
		}
		else
		{
			if( fgets( szInput, sizeof(szInput), stdin ) && 
				( szInput[0] == 'q' || szInput[0] == 'Q' ) )
			{
				pController->Stop( );
				
				ulStop = time( 0 );
				
				while( !pController->Ishalt( ) )
				{
// 					if( time( 0 ) - ulStop > MAX_WAIT_TIME )
// 						break;
					
					pController->yield( );
				}
				
				break;
			}
			else
				pController->yield( );
		}
	}
	
	pController->Release( );
	
	return 0;
}
