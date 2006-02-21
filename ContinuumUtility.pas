unit ContinuumUtility;

interface

uses Windows;


(* * * * * * * * * * * * * * * * * * *
 *          Date Conversion          *
 * * * * * * * * * * * * * * * * * * *)
  function ETimeToDateTime( ETime: DWORD ): TDateTime;
  function DateTimeToETime( DateTime: TDateTime ): DWORD;


(* * * * * * * * * * * * * * * * * * *
 *          Symbol Lookup            *
 * * * * * * * * * * * * * * * * * * *)
  function IsSymbolValid( const TheSymbol: AnsiString; Timeout: LongWord ): Boolean;


(* * * * * * * * * * * * * * * * * * *
 *       Price Type Conversion       *
 * * * * * * * * * * * * * * * * * * *)

type
  TccPriceType = ( ptUndefined, ptWhole, ptHalves, ptQuarters, pt8ths, pt16ths, pt32nds, pt64ths, pt128ths, pt256ths,
                   pt256thsAs8ths, pt256thsAs32nds, pt256thsAs32ndsAndHalf32nds, pt256thsAs32ndsAndQuarter32nds,
                   pt256thsAs64ths, pt256thsAs64thsAndHalf64ths, pt256thsAs256, pt400ths, pt512ths, pt1024ths,
                   ptDecimal1, ptDecimal2, ptDecimal3, ptDecimal4, ptDecimal5,  ptDecimal6, ptDecimal7, ptDecimal8,
                   ptDecimal9, ptDecimal10, ptTimes10, ptTimes100, ptDate, ptTime, ptCommas, ptASCII );

  function IntegerPriceToReal( const Price: DWORD; const PriceType: TccPriceType ): Double;
  function RealPriceToInteger( const Price: Double; const PriceType: TccPriceType ): DWORD;
  function FormatIntegerPrice( const Price: DWORD; const PriceType: TccPriceType ): AnsiString;
  function FormatRealPrice( const Price: Double; const PriceType: TccPriceType ): AnsiString;
  function PriceTypeEnumToConst( const ThePriceType: TccPriceType ): Byte;
  function PriceTypeConstToEnum( const ThePriceType: Byte ): TccPriceType;


(* * * * * * * * * * * * * * * * * * *
 *    Event Sink Utility Methods     *
 * * * * * * * * * * * * * * * * * * *)
  function  CreateEventSinkWindow( ClassName: AnsiString; WindowProc: TFNWndProc; TheObject: TObject ): HWND;
  procedure DestroyEventSinkWindow( TheWindow: HWND );
  procedure ProcessOneEventMessage( TheWindow: HWND );



implementation

uses SysUtils, ContinuumAPI;


const
  OneDay        = 1.0;
  OneHour       = OneDay / 24;
  OneMinute     = OneHour / 60;
  OneSecond     = OneMinute / 60;
  ETimeInterval = OneSecond * 2;
  ETimeEpoch    = -36157.0;


const
  PT_HalvesFactor    = 0.5;
  PT_QuartersFactor  = 0.25 ;
  PT_8thsFactor      = 0.125;
  PT_16thsFactor     = 0.0625;
  PT_32ndsFactor     = 0.03125;
  PT_64thsFactor     = 0.015625;
  PT_128thsFactor    = 0.0078125;
  PT_256thsFactor    = 0.00390625;
  PT_400thsFactor    = 0.0025;
  PT_512thsFactor    = 0.001953125;
  PT_1024thsFactor   = 0.0009765625;
  PT_Decimal1Factor  = 0.1;
  PT_Decimal2Factor  = 0.01;
  PT_Decimal3Factor  = 0.001;
  PT_Decimal4Factor  = 0.0001;
  PT_Decimal5Factor  = 0.00001;
  PT_Decimal6Factor  = 0.000001;
  PT_Decimal7Factor  = 0.0000001;
  PT_Decimal8Factor  = 0.00000001;
  PT_Decimal9Factor  = 0.000000001;
  PT_Decimal10Factor = 0.0000000001;
  PT_TensFactor      = 10;
  PT_HundredsFactor  = 100;



(* * * * * * * * * * * * * * * * * * *
 *  Date Conversion Utility Methods  *
 * * * * * * * * * * * * * * * * * * *)

function ETimeToDateTime( ETime: DWORD ): TDateTime;
begin
  // Compute 2-second intervals since 1801 as a TDateTime.
  // Easier and faster than using the Continuum methods.
  Result := ETimeEpoch + ( ETime * ETimeInterval );
end;


function DateTimeToETime( DateTime: TDateTime ): DWORD;
begin
  // Compute 2-second intervals since 1801 as a ETime.
  // Easier and faster than using the Continuum methods.
  Result := Round( ( DateTime - ETimeEpoch ) / ETimeInterval );
end;


(* * * * * * * * * * * * * * * * * * *
 *       Symbol Lookup Methods       *
 * * * * * * * * * * * * * * * * * * *)
function IsSymbolValid( const TheSymbol: AnsiString; Timeout: LongWord ): Boolean;
var
  SnapshotSet: Pointer;
  StartTick:   DWORD;
begin
  // Make a quick check to see if the symbol is already known to be good.
  Result := ( CC_CheckSymbolStatus( PChar( TheSymbol ) ) = SYMBOL_STATUS_OK );

  // If the symbol is not known to be good...
  if ( not Result ) then begin

    // Allocate a snapshot set.
    SnapshotSet := CC_CreateSnapshotSet( PChar( TheSymbol ) );
    try // ..finally

      // Make sure snapshot set was properly constructed.
      if ( SnapshotSet <> nil ) then begin

        // If snapshot set initializes...
        if SS_Init( SnapshotSet ) then begin

          // Note the time we started waiting.
          StartTick := Windows.GetTickCount;

          // Wait around for initialization to finish.
          while SS_IsRequestPending( SnapshotSet ) do begin

            // Break loop if timeout.
            if ( ( Windows.GetTickCount - StartTick ) > Timeout ) then begin
              Break;
            end; // if

            // Yield timeslice.
            Windows.Sleep( 0 );
          end;

          // Check status of symbol.
          Result := ( CC_CheckSymbolStatus( PChar( TheSymbol ) ) = SYMBOL_STATUS_OK );
        end;

      end; // if

    // Ensure allocated snapshot set is destroyed.
    finally
      CC_DeleteSnapshotSet( SnapshotSet );
    end;
  end;
end;


(* * * * * * * * * * * * * * * * * * *
 *   Price Type Conversion Methods   *
 * * * * * * * * * * * * * * * * * * *)
function IntegerPriceToReal( const Price: DWORD; const PriceType: TccPriceType ): Double;
begin
  case ( PriceType ) of
    ptHalves:                Result := Price * PT_HalvesFactor;
    ptQuarters:              Result := Price * PT_QuartersFactor;
    pt8ths:                  Result := Price * PT_8thsFactor;
    pt16ths:                 Result := Price * PT_16thsFactor;
    pt32nds:                 Result := Price * PT_32ndsFactor;
    pt64ths:                 Result := Price * PT_64thsFactor;
    pt128ths:                Result := Price * PT_128thsFactor;
    pt256ths..pt256thsAs256: Result := Price * PT_256thsFactor;
    pt400ths:                Result := Price * PT_400thsFactor;
    pt512ths:                Result := Price * PT_512thsFactor;
    pt1024ths:               Result := Price * PT_1024thsFactor;
    ptDecimal1:              Result := Price * PT_Decimal1Factor;
    ptDecimal2:              Result := Price * PT_Decimal2Factor;
    ptDecimal3:              Result := Price * PT_Decimal3Factor;
    ptDecimal4:              Result := Price * PT_Decimal4Factor;
    ptDecimal5:              Result := Price * PT_Decimal5Factor;
    ptDecimal6:              Result := Price * PT_Decimal6Factor;
    ptDecimal7:              Result := Price * PT_Decimal7Factor;
    ptDecimal8:              Result := Price * PT_Decimal8Factor;
    ptDecimal9:              Result := Price * PT_Decimal9Factor;
    ptDecimal10:             Result := Price * PT_Decimal10Factor;
    ptTimes10:               Result := Price * PT_TensFactor;
    ptTimes100:              Result := Price * PT_HundredsFactor;
    ptAscii:                 Result := Price * PT_256thsFactor;
    ptTime:                  Result := Price * ETimeInterval;
    ptDate:                  Result := ETimeToDateTime( Price );
    else                     Result := Price;
  end;
end;


function RealPriceToInteger( const Price: Double; const PriceType: TccPriceType ): DWORD;
begin
  case ( PriceType ) of
    ptHalves:                Result := Round( Price / PT_HalvesFactor );
    ptQuarters:              Result := Round( Price / PT_QuartersFactor );
    pt8ths:                  Result := Round( Price / PT_8thsFactor );
    pt16ths:                 Result := Round( Price / PT_16thsFactor );
    pt32nds:                 Result := Round( Price / PT_32ndsFactor );
    pt64ths:                 Result := Round( Price / PT_64thsFactor );
    pt128ths:                Result := Round( Price / PT_128thsFactor );
    pt256ths..pt256thsAs256: Result := Round( Price / PT_256thsFactor );
    pt400ths:                Result := Round( Price / PT_400thsFactor );
    pt512ths:                Result := Round( Price / PT_512thsFactor );
    pt1024ths:               Result := Round( Price / PT_1024thsFactor );
    ptDecimal1:              Result := Round( Price / PT_Decimal1Factor );
    ptDecimal2:              Result := Round( Price / PT_Decimal2Factor );
    ptDecimal3:              Result := Round( Price / PT_Decimal3Factor );
    ptDecimal4:              Result := Round( Price / PT_Decimal4Factor );
    ptDecimal5:              Result := Round( Price / PT_Decimal5Factor );
    ptDecimal6:              Result := Round( Price / PT_Decimal6Factor );
    ptDecimal7:              Result := Round( Price / PT_Decimal7Factor );
    ptDecimal8:              Result := Round( Price / PT_Decimal8Factor );
    ptDecimal9:              Result := Round( Price / PT_Decimal9Factor );
    ptDecimal10:             Result := Round( Price / PT_Decimal10Factor );
    ptTimes10:               Result := Round( Price / PT_TensFactor );
    ptTimes100:              Result := Round( Price / PT_HundredsFactor );
    ptAscii:                 Result := Round( Price / PT_256thsFactor );
    ptTime:                  Result := Round( Price / ETimeInterval );
    ptDate:                  Result := DateTimeToETime( Price );
    else                     Result := Round( Price );
  end;
end;


function FormatIntegerPrice( const Price: DWORD; const PriceType: TccPriceType ): AnsiString;
var
  Buffer: Array[0..31] of Char;
begin
  // Use API to format price into a buffer.
  CC_PriceToBuff( Price, PriceTypeEnumToConst( PriceType ), Buffer, SizeOf( Buffer ) );

  // Return buffer as a string.
  Result := Buffer;
end;


function FormatRealPrice( const Price: Double; const PriceType: TccPriceType ): AnsiString;
begin
  Result := FormatIntegerPrice( RealPriceToInteger( Price, PriceType ), PriceType );
end;


function PriceTypeEnumToConst( const ThePriceType: TccPriceType ): Byte;
begin
  case ( ThePriceType ) of
    ptWhole:                        Result := PT_Whole;
    ptHalves:                       Result := PT_Halves;
    ptQuarters:                     Result := PT_Quarters;
    pt8ths:                         Result := PT_8ths;
    pt16ths:                        Result := PT_16ths;
    pt32nds:                        Result := PT_32nds;
    pt64ths:                        Result := PT_64ths;
    pt128ths:                       Result := PT_128ths;
    pt256ths:                       Result := PT_256ths;
    pt256thsAs8ths:                 Result := PT_256thsAs8ths;
    pt256thsAs32nds:                Result := PT_256thsAs32nds;
    pt256thsAs32ndsAndHalf32nds:    Result := PT_256thsAs32ndsAndHalf32nds;
    pt256thsAs32ndsAndQuarter32nds: Result := PT_256thsAs32ndsAndQuarter32nds;
    pt256thsAs64ths:                Result := PT_256thsAs64ths;
    pt256thsAs64thsAndHalf64ths:    Result := PT_256thsAs64thsAndHalf64ths;
    pt256thsAs256:                  Result := PT_256thsAs256;
    pt400ths:                       Result := PT_400ths;
    pt512ths:                       Result := PT_512ths;
    pt1024ths:                      Result := PT_1024ths;
    ptDecimal1:                     Result := PT_Decimal1;
    ptDecimal2:                     Result := PT_Decimal2;
    ptDecimal3:                     Result := PT_Decimal3;
    ptDecimal4:                     Result := PT_Decimal4;
    ptDecimal5:                     Result := PT_Decimal5;
    ptDecimal6:                     Result := PT_Decimal6;
    ptDecimal7:                     Result := PT_Decimal7;
    ptDecimal8:                     Result := PT_Decimal8;
    ptDecimal9:                     Result := PT_Decimal9;
    ptDecimal10:                    Result := PT_Decimal10;
    ptTimes10:                      Result := PT_Times10;
    ptTimes100:                     Result := PT_Times100;
    ptDate:                         Result := PT_Date;
    ptTime:                         Result := PT_Time;
    ptCommas:                       Result := PT_Commas;
    ptASCII:                        Result := PT_ASCII;
    else                            Result := PT_Undefined;
  end; // case
end;


function PriceTypeConstToEnum( const ThePriceType: Byte ): TccPriceType;
begin
  case ( ThePriceType ) of
    PT_Whole:                        Result := ptWhole;
    PT_Halves:                       Result := ptHalves;
    PT_Quarters:                     Result := ptQuarters;
    PT_8ths:                         Result := pt8ths;
    PT_16ths:                        Result := pt16ths;
    PT_32nds:                        Result := pt32nds;
    PT_64ths:                        Result := pt64ths;
    PT_128ths:                       Result := pt128ths;
    PT_256ths:                       Result := pt256ths;
    PT_256thsAs8ths:                 Result := pt256thsAs8ths;
    PT_256thsAs32nds:                Result := pt256thsAs32nds;
    PT_256thsAs32ndsAndHalf32nds:    Result := pt256thsAs32ndsAndHalf32nds;
    PT_256thsAs32ndsAndQuarter32nds: Result := pt256thsAs32ndsAndQuarter32nds;
    PT_256thsAs64ths:                Result := pt256thsAs64ths;
    PT_256thsAs64thsAndHalf64ths:    Result := pt256thsAs64thsAndHalf64ths;
    PT_256thsAs256:                  Result := pt256thsAs256;
    PT_400ths:                       Result := pt400ths;
    PT_512ths:                       Result := pt512ths;
    PT_1024ths:                      Result := pt1024ths;
    PT_Decimal1:                     Result := ptDecimal1;
    PT_Decimal2:                     Result := ptDecimal2;
    PT_Decimal3:                     Result := ptDecimal3;
    PT_Decimal4:                     Result := ptDecimal4;
    PT_Decimal5:                     Result := ptDecimal5;
    PT_Decimal6:                     Result := ptDecimal6;
    PT_Decimal7:                     Result := ptDecimal7;
    PT_Decimal8:                     Result := ptDecimal8;
    PT_Decimal9:                     Result := ptDecimal9;
    PT_Decimal10:                    Result := ptDecimal10;
    PT_Times10:                      Result := ptTimes10;
    PT_Times100:                     Result := ptTimes100;
    PT_Date:                         Result := ptDate;
    PT_Time:                         Result := ptTime;
    PT_Commas:                       Result := ptCommas;
    PT_ASCII:                        Result := ptASCII;
    else                             Result := ptUndefined;
  end; // case
end;


(* * * * * * * * * * * * * * * * * * *
 *    Event Sink Utility Methods     *
 * * * * * * * * * * * * * * * * * * *)

// Use this method to create a message-handling window without the Forms unit.
function CreateEventSinkWindow( ClassName: AnsiString; WindowProc: TFNWndProc; TheObject: TObject ): HWND;
var
  WindowClassName: AnsiString;
  TheWindowClass:  TWndClass;
  Unused:          TWndClass;
begin
  // Derive a class name for the window from the object class name.
  WindowClassName := ClassName + 'EventSink';

  // Set up window class info structure. All but three elements zeroed.
  FillChar( TheWindowClass, SizeOf( TheWindowClass ), 0 );
  TheWindowClass.hInstance     := HInstance;
  TheWindowClass.lpfnWndProc   := WindowProc;
  TheWindowClass.lpszClassName := PChar( WindowClassName );

  // Check whether the class is already registered. If so, unregister to ensure class info is correct.
  // Raise exception if class can't be unregistered.
  if ( Windows.GetClassInfo(HInstance, TheWindowClass.lpszClassName, Unused ) ) then begin
    Win32Check( Windows.UnregisterClass( TheWindowClass.lpszClassName, HInstance ) );
  end; // if

  // Register the event sink window class. Raise exception on failure.
  Win32Check( LongBool( Windows.RegisterClass( TheWindowClass ) ) );

  // Create the window. Raise exception on failure.
  Result := Windows.CreateWindowEx( WS_EX_TOOLWINDOW,
                                    TheWindowClass.lpszClassName,
                                    nil, WS_POPUP, 0, 0, 0, 0, 0, 0,
                                    HInstance, nil);
  Win32Check( LongBool( Result ) );

  // Set the window's user data to point to the object. Raise exception on failure.
  // Failure checking is a bit funky because SetWindowLong usually will return a zero.
  Windows.SetLastError( 0 );
  Windows.SetWindowLong( Result, GWL_USERDATA, Integer( TheObject ) );
  Win32Check( not ( LongBool( Windows.GetLastError ) ) );
end;


// Use this method to destroy a message-handling window created with CreateEventSinkWindow.
procedure DestroyEventSinkWindow( TheWindow: HWND );
begin
  // Destroy the window. We don't care if this succeeds.
  Windows.DestroyWindow( TheWindow );
end;


// Use this method to process one message at a time in a given message-handling window
// without pumping messages in other windows, as would Application.ProcessMessages.
// Useful for serializing otherwise asynchronous processes, like connecting the client.
// Much more efficient than polling. Use a timer or other message to break wait state.
procedure ProcessOneEventMessage( TheWindow: HWND );
var
  TheMessage: TMsg;
  Result:     LongInt;
begin
  // Fetch a message. Wait for one to appear.
  Result := LongInt( Windows.GetMessage( TheMessage, TheWindow, 0, 0 ) );

  // If we really got a message, translate and dispatch it.
  if ( Result >= 0 ) then begin
    Windows.TranslateMessage( TheMessage );
    Windows.DispatchMessage( TheMessage );
  end  // if

  // If an error occurred, raise an exception.
  else begin
    SysUtils.RaiseLastWin32Error;
  end; // else
end;


end.

