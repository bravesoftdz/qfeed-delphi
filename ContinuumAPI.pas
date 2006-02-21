unit ContinuumAPI;

interface

uses Windows, Messages, SysUtils;


(* * * * * * * * * * * * * * * * * * *
 *             Constants             *
 * * * * * * * * * * * * * * * * * * *)

// ContinuumClient Status Message constants
const
  WM_CONTINUUMCLIENT      = WM_USER + 17024;

  CCLIENTMSG_LOGON        = 0;	// Sent after connecting, asking you to logon
  CCLIENTMSG_LOGONRESULT  = 1;	// Sent after you logon. Tells you the status of the logon
  CCLIENTMSG_LOGGEDOFF    = 2;	// Sent if you've been logged off
  CCLIENTMSG_READY        = 3;	// System ready. Do not start calling functions until you receive this status
  CCLIENTMSG_STATUS       = 4;	// lParam is a PChar message

// Logon Result constants
const
  LOR_WAIT_TIMED_OUT      = -100;
  LOR_SERVER_CLOSED       = -3;
  LOR_MAX_CONNECTIONS     = -2;
  LOR_USER_NOT_FOUND      = -1;
  LOR_PASSWORD_NOT_FOUND  =  0;
  LOR_SUCCESS             =  1;

// Connection Status constants
const
  CNXSTAT_UNKNOWN              = 0;
  CNXSTAT_CONNECTIONTIMEDOUT   = 1;
  CNXSTAT_CONNECTING           = 2;
  CNXSTAT_CONNECTED            = 3;
  CNXSTAT_CONNECTIONFAILED     = 4;
  CNXSTAT_DISCONNECTED         = 5;
  CNXSTAT_LOGGEDON             = 6;
  CNXSTAT_LOGONFAILED          = 7;
  CNXSTAT_LOGGINGON            = 8;
  CNXSTAT_SHUTTINGDOWN         = 9;
  CNXSTAT_SHUTDOWN             = 10;
  CNXSTAT_OK                   = 11;
  CNXSTAT_QUESTIONABLE         = 12;
  CNXSTAT_THEREISABETTERSERVER = 13;
  CNXSTAT_USERDISCONNECTED     = 14;

// Record Index constants
const
  RECIX_UNKNOWN = MINLONG;
  RECIX_MIN     = MINLONG + 100; // First 100 entries are reserved.
  RECIX_MAX     = MAXLONG;

// Symbol Status constants
const
  SYMBOL_STATUS_OK       = 0;
  SYMBOL_STATUS_PENDING  = 1;
  SYMBOL_STATUS_NOTFOUND = 2;

// Client Parameter constants
  CCPARAM_MSBARCACHETIMEOUT = 0;
  CCPARAM_MSBASCACHETIMEOUT = 1;
  CCPARAM_HOTLISTITEMS      = 2;

// Price type constants  
const
  PT_Undefined                    = $FF;
  PT_Whole                        = 0;
  PT_Halves                       = 1;
  PT_Quarters                     = 2;
  PT_8ths                         = 3;
  PT_16ths                        = 4;
  PT_32nds                        = 5;
  PT_64ths                        = 6;
  PT_128ths                       = 7;
  PT_256ths                       = 8;
  PT_512ths                       = 9;
  PT_1024ths                      = 10;
  PT_Decimal1                     = 11;
  PT_Decimal2                     = 12;
  PT_Decimal3                     = 13;
  PT_Decimal4                     = 14;
  PT_Decimal5                     = 15;
  PT_Decimal6                     = 16;
  PT_Decimal7                     = 17;
  PT_Decimal8                     = 18;
  PT_Decimal9                     = 19;
  PT_Decimal10                    = 20;
  PT_Times10                      = 21;
  PT_Times100                     = 22;
  PT_Special256Start              = 31;
  PT_256thsAs64thsAndHalf64ths    = 31;
  PT_256thsAs32ndsAndHalf32nds    = 32;
  PT_256thsAs32ndsAndQuarter32nds = 33;
  PT_256thsAs256                  = 35;
  PT_256thsAs64ths                = 36;
  PT_256thsAs32nds                = 37;
  PT_256thsAs8ths                 = 38;
  PT_Special256End                = 38;
  PT_400ths                       = 39;
  PT_Date                         = 40;
  PT_Time                         = 41;
  PT_Commas                       = 42;
  PT_ASCII                        = 43;

// Recordset Autoupdate values
const
  AU_NOUPDATES    = 0;
  AU_SCROLL       = 1;
  AU_EXTENDFUTURE = 2;
  AU_FULLRANGE    = 3;
  AU_DISABLED     = 4;

// RecordSet Session Flags
const
  TRSFLAG_SESSION1    = $01;
  TRSFLAG_SESSION2    = $02;
  TRSFLAG_SESSION3    = $04;
  TRSFLAG_SESSION4    = $08;
  TRSFLAG_SESSION5    = $10;
  TRSFLAG_SESSION6    = $20;
  TRSFLAG_SESSION7    = $40;
  TRSFLAG_SESSION8    = $80;
  TRSFLAG_ALLSESSIONS = $FF;

// RecordSet DataUpdate types
const
  TRSMSG_SCROLL          = 0;
  TRSMSG_CHANGE          = 1;
  TRSMSG_REQUESTCOMPLETE = 2;

// Recordset GetFieldIx names
type
  TBarFieldIndices  = ( trsOpen, trsHigh, trsLow, trsClose, trsVolume, trsCorpActs,
                       trsOpenInt, trsFilterHigh, trsFilterLow );
  TTickFieldIndices = ( trsTime, trsSeconds, trsFlags, trsBASCodes, trsIndicator, trsPriceType,
                        trsExchange, trsPrice, trsSize, trsETrade, trsTick );
  TBarFieldNames   = Array[ TBarFieldIndices ]  of AnsiString;
  TTickFieldNames  = Array[ TTickFieldIndices ] of AnsiString;


const
  // Bars
  TRS_SZOPEN      = 'Open';
  TRS_SZHIGH      = 'High';
  TRS_SZLOW       = 'Low';
  TRS_SZCLOSE     = 'Close';
  TRS_SZVOLUME    = 'Volume';
  TRS_SZCORPACTS  = 'CorpActs';
  TRS_SZOPENINT   = 'OpenInt';
  TRS_FILTERHIGH  = 'FilterHigh';
  TRS_FILTERLOW   = 'FilterLow';

  BarFieldNames: TBarFieldNames = ( TRS_SZOPEN, TRS_SZHIGH, TRS_SZLOW, TRS_SZCLOSE, TRS_SZVOLUME,
                                    TRS_SZCORPACTS, TRS_SZOPENINT, TRS_FILTERHIGH, TRS_FILTERLOW );

  // Time & Sales
  TRS_TIME        = 'Time';
  TRS_SECONDS     = 'Seconds';
  TRS_FLAGS       = 'Flags';
  TRS_SZBASCODES  = 'BASCodes';
  TRS_SZINDICATOR = 'Indicator';
  TRS_PRICETYPE   = 'Price Type';
  TRS_SZEXCHANGE  = 'Exchange';
  TRS_SZPRICE     = 'Price';
  TRS_SZSIZE      = 'Size';
  TRS_ETRADE      = 'ETrade';
  TRS_TICK        = 'Tick';

  TickFieldNames: TTickFieldNames = ( TRS_TIME, TRS_SECONDS, TRS_FLAGS, TRS_SZBASCODES, TRS_SZINDICATOR, TRS_PRICETYPE,
                                      TRS_SZEXCHANGE, TRS_SZPRICE, TRS_SZSIZE, TRS_ETRADE, TRS_TICK );


// Time & Sales Flag Values
const
  ETF_BATMASK        = $0003; // 00xx
  ETF_TRDONLY        = $0000; // 0000
  ETF_ASK            = $0001; // 0001
  ETF_BID            = $0002; // 0010
  ETF_INFO           = $0003; // 0011 // new
  ETF_BBO            = $0004; // best bid or offer: for quotes
  ETF_SPECIAL        = $0008;
  ETF_COMPOSITE_OPEN = $0010;
  ETF_COMPOSITE_HIGH = $0020;
  ETF_COMPOSITE_LOW  = $0040;
  ETF_UPDATE_LAST    = $0080;
  ETF_UPDATE_VOLUME  = $0100;
  ETF_SUBTRACT_VOL   = $0200;
  ETF_CANCEL         = $0400;
  ETF_FILTERED       = $0800;
  ETF_TRADEAT_BID    = $1000; // trade occurred at bid
  ETF_TRADEAT_ASK    = $2000; // trade occurred at ask
  ETF_OUTOFSEQ       = $4000;
  ETF_UNUSED         = $8000; // old MMQuote flag


// RecordSet.GetRecDWord values in field "BASCodes"
const
  BASC_TRADE      = 0;
  BASC_BID        = 1;
  BASC_BESTBID    = 2;
  BASC_ASK        = 3;
  BASC_BESTASK    = 4;

// Values returned by RecordSet.Init
const
  INIT_FAILURE          = 0;
  INIT_SUCCESS          = 1;
  INIT_SUCCESS_CACHED   = 2;
  INIT_SUCCESS_COMPLETE = 3;

// TypeFlags used by RecordSet.GetETime
  ETIME_BEGIN = 1;
  ETIME_END   = 0;

// SnapshotSet Data Change type
const
  SSSMSG_CHANGE = 1;

// SnapshotSet fields.
const
  SST_Open                  = 0;
  SST_High                  = 1;
  SST_Low                   = 2;
  SST_Trade                 = 3;
  SST_Yest                  = 4;
  SST_Unused                = 5;
  SST_Bid                   = 6;
  SST_Ask                   = 7;
  SST_BBid                  = 8;
  SST_BAsk                  = 9;
  SST_Volume                = 10;
  SST_OpenInt               = 11;
  SST_TradeSize             = 12;
  SST_BidSize               = 13;
  SST_AskSize               = 14;
  SST_BBidSize              = 15;
  SST_BAskSize              = 16;
  SST_TradeExg              = 17;
  SST_BidExg                = 18;
  SST_AskExg                = 19;
  SST_BBidExg               = 20;
  SST_BAskExg               = 21;
  SST_Trade2                = 22;
  SST_Trade3                = 23;
  SST_Trade4                = 24;
  SST_Trade5                = 25;
  SST_TickVol               = 26;
  SST_TradeTime             = 27;
  SST_YearHi                = 28;
  SST_YearLo                = 29;
  SST_200DayAvgPrice        = 30;
  SST_65DayAvgVol           = 31;
  SST_Title                 = 32;
  SST_Symbol                = 33;
  SST_Tick                  = 34;
  SST_Net                   = 35;
  SST_NetPct                = 36;
  SST_TradeInRangePct       = 37;
  SST_BlockVolume           = 38;
  SST_BlockTrades           = 39;
  SST_VolAtAsk              = 40;
  SST_TickVolAtAsk          = 41;
  SST_VolAtBid              = 42;
  SST_TickVolAtBid          = 43;
  SST_TickMagnitude         = 44;
  SST_TradeInYearlyRange    = 45;
  SST_ValueAtAsk            = 46;
  SST_ValueAtBid            = 47;
  SST_TradingIndc           = 48;
  SST_DayValue              = 49;
  SST_MoneyFlow             = 50;
  SST_VWAP                  = 51;
  SST_TradeSizeSum          = 52; // Do not use.
  SST_UpTickVol             = 53;
  SST_UpTicks               = 54;
  SST_UpTickValue           = 55;
  SST_DnTickVol             = 56;
  SST_DnTicks               = 57;
  SST_DnTickValue           = 58;
  SST_Settle                = 59;
  SST_QuoteSize             = 60;
  SST_BidAskSpread          = 61;
  SST_FinancialsDate        = 64;
  SST_Beta                  = 65;
  SST_SharesOutstanding     = 66;
  SST_Float                 = 67;
  SST_Dividend              = 68;
  SST_InsideOwnedPct        = 69;
  SST_InstitutionalOwnedPct = 70;
  SST_ShortInt              = 71;
  SST_ShortIntPrev          = 72;
  SST_ShortIntRatio         = 73;
  SST_CashFlowPerSh         = 74;
  SST_SalesPerSh            = 75;
  SST_ReturnOnEquity        = 76;
  SST_ReturnOnAssets        = 77;
  SST_GrossMargin           = 78;
  SST_OperatingMargin       = 79;
  SST_PretaxMargin          = 80;
  SST_IndustryCode          = 81;
  SST_IndustryName          = 82;
  SST_SectorName            = 83;
  SST_InventoryTurnover     = 84;
  SST_AssetTurnover         = 85;
  SST_ReceivablesTurnover   = 86;
  SST_RevenuePerEmployee    = 87;
  SST_EarningsPerSh         = 88;
  SST_RevenueGrowthRate     = 89;
  SST_EPSGrowthRate         = 90;
  SST_DebtEquityRatioQtr    = 91;
  SST_LTDebtEquityRationQtr = 92;
  SST_CurrentRatioQtr       = 93;
  SST_QuickRatioQtr         = 94;
  SST_InsiderPurchased      = 95;
  SST_InsiderSold           = 96;
  SST_BookValuePerSh        = 97;
  SST_MarketCapitalization  = 98;
  SST_PERatio               = 99;
  SST_DividendYield         = 100;

  SST_FieldCount            = 98;

// SymbolSet Data Change types
const
  SYMSET_NEWSYMBOLS      = 1;
  SYMSET_NEWTITLES       = 2;
  SYMSET_REQUESTCOMPLETE = 3;

// SymbolSet Field Indices
  SYFIX_SYMBOL = 0;
  SYFIX_TITLE  = 1;

// TopListSet Field indices
const
  TLFIX_SYMBOL = 0;
  TLFIX_BASIS  = 1;
  TLFIX_TITLE  = 2;

// Level 2 stuff
const
  LIIFIX_TIME        = 0;
  LIIFIX_PRICE       = 1;
  LIIFIX_SIZE        = 2;
  LIIFIX_MMID        = 3;
  LIIFIX_PTYPE       = 4;
  LIIFIX_INDC        = 5;
  LIIFIX_SIZECHANGE  = 6; // Returns +1 for increase in size, -1 for decrease, and 0 for no change
  LIIFIX_PRICECHANGE = 7; // Returns +1 for increase in price, -1 for decrease, and 0 for no change

  LIICFLAG_TIME  = $00000001;
  LIICFLAG_PRICE = $00000002;
  LIICFLAG_SIZE  = $00000004;
  LIICFLAG_MMID  = $00000008;
  LIICFLAG_PTYPE = $00000010;
  LIICFLAG_INDC  = $00000020;
  LIICFLAG_ALL   = $0000003f;

  LII_ITYPE_SYMBOL = 0;
  LII_ITYPE_INIT   = 1;
  LII_ITYPE_UPDATE = 2;
  LII_ITYPE_MMID   = 3;


(* * * * * * * * * * * * * * * * * * *
 *      Event Sink Method Types      *
 * * * * * * * * * * * * * * * * * * *)
type
  // Continuum Client sink method types
  TccLogOnMethod         = procedure( UserName: PChar; Password: PChar ); stdcall;
  TccLogonResultMethod   = procedure( Status: LongInt );                  stdcall;
  TccLoggedOffMethod     = procedure;                                     stdcall;
  TccReadyMethod         = procedure;                                     stdcall;
  TccStatusMessageMethod = procedure( StatusMessage: PChar );             stdcall;

  // Data Set method types
  TccDataChange  = procedure( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD );                stdcall;
  TssFieldChange = procedure( Handle: Pointer; FieldCount: Byte; FieldIndices: PByte );                          stdcall;
  Tl2DataChange  = procedure( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD; Param3: DWORD ); stdcall;



(* * * * * * * * * * * * * * * * * * *
 *     Event Sink vtable mockups     *
 * * * * * * * * * * * * * * * * * * *)
type
  TSinkMockup = packed record
    VTable:     Pointer;
    SinkObject: TObject;
  end;
  PSinkMockup = ^TSinkMockup;

  TConnectStatusVTable = packed record
    DoLogon:         TccLogOnMethod;
    OnLogon:         TccLogonResultMethod;
    OnLogoff:        TccLoggedOffMethod;
    OnReady:         TccReadyMethod;
    OnStatusMessage: TccStatusMessageMethod;
  end;
  PConnectStatusVTable = ^TConnectStatusVTable;

  TStandardSinkVTable = packed record
    OnDataChange: TccDataChange;
  end;
  PStandardSinkVTable = ^TStandardSinkVTable;

  TSnapshotSinkVTable = packed record
    OnDataChange:  TccDataChange;
    OnFieldChange: TssFieldChange;
  end;
  PSnapshotSinkVTable = ^TSnapshotSinkVTable;

  TLevelIISetSinkVTable = packed record
    OnDataChange: Tl2DataChange;
  end;
  PLevelIISetSinkVTable = ^TLevelIISetSinkVTable;


(* * * * * * * * * * * * * * * * * * *
 *      Event Sink base objects      *
 * * * * * * * * * * * * * * * * * * *)
type

  TContinuumEventSink = class( TObject )
  protected
    constructor Create;
  private
    FSinkMockup: TSinkMockup;
  protected
    property SinkMockup: TSinkMockup  read FSinkMockup;
  end;

  
  EConnectStatus = class( TContinuumEventSink )
  protected
    constructor Create;
  private
    FSinkVTable: TConnectStatusVTable;
  private
    procedure DoLoggingOn( UserName: PChar; Password: PChar );
    procedure DoLogonResult( Status: LongInt );
    procedure DoLoggedOff;
    procedure DoReady;
    procedure DoStatusMessage( StatusMessage: PChar );
  protected
    property SinkVTable: TConnectStatusVTable  read FSinkVTable;
  protected
    procedure DoLogon( UserName: PChar; Password: PChar ); virtual; abstract;
    procedure OnLogon( Status: LongInt );                  virtual; abstract;
    procedure OnLogoff;                                    virtual; abstract;
    procedure OnReady;                                     virtual; abstract;
    procedure OnStatusMessage( StatusMessage: PChar );     virtual; abstract;
  end;


  TContinuumStandardEventSink = class( TContinuumEventSink )
  protected
    constructor Create;
  private
    FSinkVTable: TStandardSinkVTable;
  private
    procedure DoDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD );
  protected
    property SinkVTable: TStandardSinkVTable  read FSinkVTable;
  protected
    procedure OnDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD ); virtual; abstract;
  end;


  ITRecSetSink = class( TContinuumStandardEventSink )
    // Nothing to add.
  end;


  ISymbolSetSink = class( TContinuumStandardEventSink )
    // Nothing to add.
  end;


  ITLSetSink = class( TContinuumStandardEventSink )
    // Nothing to add.
  end;


  ISSSetSink = class( TContinuumEventSink )
  protected
    constructor Create;
  private
    FSinkVTable: TSnapshotSinkVTable;
  private
    procedure DoDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD );
    procedure DoFieldChange( Handle: Pointer; FieldCount: Byte; FieldIndices: PByte );
  protected
    property SinkVTable: TSnapshotSinkVTable  read FSinkVTable;
  protected
    procedure OnDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD ); virtual; abstract;
    procedure OnFieldChange( Handle: Pointer; FieldCount: Byte; FieldIndices: Array of Byte );  virtual; abstract;
  end;


  ILevelIISetSink = class( TContinuumEventSink )
  protected
    constructor Create;
  private
    FSinkVTable: TLevelIISetSinkVTable;
  private
    procedure DoDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD; Param3: DWORD );
  protected
    property SinkVTable: TLevelIISetSinkVTable  read FSinkVTable;
  protected
    procedure OnDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD; Param3: DWORD ); virtual; abstract;
  end;




procedure CC_BuildDemoFile( ScriptFile: PChar );                                                                  register;
function  CC_CheckPermission( Permission: PChar ): DWORD;                                                         register;
function  CC_CheckSymbolStatus( Symbol: PChar ): ShortInt;                                                        register;
function  CC_ConnectDirect( UserName: PChar; Password: PChar; Timeout: DWORD ):ShortInt;                          register;
function  CC_ConnectSink( Sink: EConnectStatus ): BOOL;                                                              register;
function  CC_ConnectWindow( Window: HWND ): BOOL;                                                                 register;
function  CC_CreateRecordSet( Expression: PChar ): Pointer;                                                       register;
function  CC_CreateSnapshotSet( Expression: PChar ): Pointer;                                                     register;
function  CC_CreateTopListSet( Expression: PChar ): Pointer;                                                      register;
function  CC_CreateLevelIISet( Expression: PChar ): Pointer;                                                      register;
function  CC_CreateSymbolSet( Expression: PChar ): Pointer;                                                       register;
procedure CC_DeleteRecordSet( RecordSet: Pointer );                                                               register;
procedure CC_DeleteSnapshotSet( SnapshotSet: Pointer );                                                           register;
procedure CC_DeleteTopListSet( TopListSet: Pointer );                                                             register;
procedure CC_DeleteLevelIISet( LevelIISet: Pointer );                                                             register;
procedure CC_DeleteSymbolSet( SymbolSet: Pointer );                                                               register;
procedure CC_Disconnect;                                                                                          register;
procedure CC_EditBASaleRecord( psz: PChar; Action: DWORD; Data: Pointer );                                        register;
procedure CC_EditSummaryRecord( psz: PChar; Action: DWORD; Data: Pointer );                                       register;
function  CC_GetBytesInRecvMessageQ: DWORD;                                                                       register;
function  CC_GetConnectionStatus: LongInt;                                                                        register;
procedure CC_GetHMS( ETime: DWORD; var Hour: DWORD; var Minute: DWORD; var Second: DWORD );                       register;
function  CC_GetLogonResultString: PChar;                                                                         register;
function  CC_GetNBytesReceived: DWORD;                                                                            register;
function  CC_GetParam( Index: LongInt ): DWORD;                                                                   register;
function  CC_GetServerDelay: DWORD;                                                                               register;
function  CC_GetServerIP: DWORD;                                                                                  register;
function  CC_GetServerName: PChar;                                                                                register;
function  CC_GetServerPort: Word;                                                                                 register;
procedure CC_GetServerTime( var SystemTime: SYSTEMTIME );                                                         register;
function  CC_GetStats( Buffer: PChar; BufferSize: LongInt ): BOOL;                                                register;
function  CC_GetUserName: PChar;                                                                                  register;
function  CC_GetUserPassword( Encrypted: BOOL ): PChar;                                                           register;
procedure CC_GetYMD( ETime: DWORD; var Year: DWORD; var Month: DWORD; var Day: DWORD );                           register;
function  CC_MakeTime(Year: DWORD; Month:  DWORD; Day: DWORD; Hour: DWORD; Minute: DWORD; Second: DWORD ): DWORD; register;
procedure CC_NextServer;                                                                                          register;
procedure CC_PriceToBuff(Price: DWORD; PriceType: DWORD; Buffer: PChar; BufferSize: LongInt );                    register;
procedure CC_SendLogon( UserName: PChar; Password: PChar );                                                       register;
procedure CC_SetNotificationWnd( Window: HWND );                                                                  register;
procedure CC_SetParam( Index: LongInt; Value: DWORD );                                                            register;
procedure CC_SetUserMode( Mode: LongInt );                                                                        register;
function  CC_SetTimer( Interval: DWORD ): DWORD;                                                                  register;
procedure CC_Shutdown;                                                                                            register;

function  RS_GetAutoUpdate( Handle: Pointer ): DWORD;                                                                           register;
function  RS_GetETime( Handle: Pointer; Index: DWORD; Flag: DWORD; var ETime: DWORD ): BOOL;                                    register;
function  RS_GetETime0( Handle: Pointer ): DWORD;                                                                               register;
function  RS_GetExpr( Handle: Pointer; Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;    register;
function  RS_GetFieldIx( Handle: Pointer; Field: PChar ): SmallInt;                                                             register;
function  RS_GetFieldTitle( Handle: Pointer; FieldIndex: LongInt; Title: PChar; BufferSize: DWORD ): BOOL;                      register;
function  RS_GetIndex( Handle: Pointer; ETime: DWORD; var Estimate: BOOL ): DWORD;                                              register;
function  RS_GetIndexingMode( Handle: Pointer ): BOOL;                                                                          register;
function  RS_GetIntervalDWord( Handle: Pointer ): DWORD;                                                                        register;
function  RS_GetIntervalString( Handle: Pointer; Output: PChar; BufferSize: DWORD; User: BOOL ): BOOL;                          register;
function  RS_GetMaxDoubleInField( Handle: Pointer; Index: LongInt ): Double;                                                    register;
function  RS_GetMaxDoubleInRange( Handle: Pointer; StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): Double;       register;
function  RS_GetMaxLongInField( Handle: Pointer; Index: LongInt ): DWORD;                                                       register;
function  RS_GetMaxLongInRange( Handle: Pointer; StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): DWORD;          register;
function  RS_GetMinDoubleInField( Handle: Pointer; Index: LongInt ): Double;                                                    register;
function  RS_GetMinDoubleInRange( Handle: Pointer; StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): Double;       register;
function  RS_GetMinLongInField( Handle: Pointer; Index: LongInt ): DWORD;                                                       register;
function  RS_GetMinLongInRange( Handle: Pointer; StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): DWORD;          register;
function  RS_GetMinutesDelayed( Handle: Pointer ): DWORD;                                                                       register;
function  RS_GetNewExpr( Handle: Pointer; Expression: PChar; BufferSize: DWORD; Base: PChar ): BOOL;                            register;
function  RS_GetNRecs( Handle: Pointer ): DWORD;                                                                                register;
function  RS_GetPriceType( Handle: Pointer; FieldIndex: LongInt ): Byte;                                                        register;
function  RS_GetRecDWord( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; var Value: DWORD ): BOOL;                 register;
function  RS_GetRecDouble( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; var Value: Double ): BOOL;               register;
function  RS_GetRecRange( Handle: Pointer; var StartIndex: LongInt; var EndIndex: LongInt ): DWORD;                             register;
function  RS_GetRecString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL; register;
function  RS_GetSink( Handle: Pointer ): ITRecSetSink;                                                                          register;
function  RS_GetTitle( Handle: Pointer; Title: PChar; BufferSize: DWORD ): BOOL;                                                register;
procedure RS_EnterRead( Handle: Pointer );                                                                                      register;
function  RS_Init( Handle: Pointer; RecordCount: DWORD; StartTime: DWORD ): LongInt;                                            register;
function  RS_IsRequestPending( Handle: Pointer ): BOOL;                                                                         register;
procedure RS_LeaveRead( Handle: Pointer );                                                                                      register;
procedure RS_Scroll( Handle: Pointer; ScrollBy: LongInt; RequestData: BOOL );                                                   register;
procedure RS_SetAutoUpdate( Handle: Pointer; AutoUpdateMode: DWORD );                                                           register;
procedure RS_SetIndexingMode( Handle: Pointer; Relative: BOOL );                                                                register;
procedure RS_SetSink( Handle: Pointer; Sink: ITRecSetSink );                                                                    register;
function  RS_SetNRecs( Handle: Pointer; NewQuantity: DWORD; AnchorZ: BOOL ): LongInt;                                           register;

procedure SS_EnterRead( Handle: Pointer );                                                                                      register;
function  SS_FillBuff( Handle: Pointer; FieldIndex: LongInt; Buffer: PChar; BufferSize: DWORD ): BOOL;                          register;
function  SS_GetDouble( Handle: Pointer; FieldIndex: LongInt; var Value: Double ): BOOL;                                        register;
function  SS_GetDWord( Handle: Pointer; FieldIndex: LongInt; var Value: DWORD ): BOOL;                                          register;
function  SS_GetEDate( Handle: Pointer ): DWORD;                                                                                register;
function  SS_GetETime( Handle: Pointer ): DWORD;                                                                                register;
function  SS_GetExpr( Handle: Pointer; Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;    register;
function  SS_GetFieldIx( Handle: Pointer; Field: PChar ): LongInt;                                                              register;
function  SS_GetFieldTitle( Handle: Pointer; FieldIndex: LongInt; Title: PChar; BufferSize: DWORD ): BOOL;                      register;
function  SS_GetMinutesDelayed( Handle: Pointer ): DWORD;                                                                       register;
function  SS_GetPriceType( Handle: Pointer; FieldIndex: LongInt ): DWORD;                                                       register;
function  SS_GetSink( Handle: Pointer ): ISSSetSink;                                                                            register;
function  SS_GetSymbolStatus( Handle: Pointer ): LongInt;                                                                       register;
function  SS_GetTitle( Handle: Pointer; Title: PChar; BufferSize: DWORD ): BOOL;                                                register;
function  SS_Init( Handle: Pointer ): BOOL;                                                                                     register;
function  SS_IsRequestPending( Handle: Pointer ): BOOL;                                                                         register;
procedure SS_LeaveRead( Handle: Pointer );                                                                                      register;
function  SS_RetDouble( Handle: Pointer; FieldIndex: LongInt ): Double;                                                         register;
function  SS_RetDWord( Handle: Pointer; FieldIndex: LongInt ): DWORD;                                                           register;
procedure SS_SetSink( Handle: Pointer; Sink: ISSSetSink );                                                                      register;

procedure L2_EnterRead( Handle: Pointer );                                                                                         register;
function  L2_GetAskRecDWord( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; var Value: DWORD ): BOOL;                 register;
function  L2_GetAskRecString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL; register;
function  L2_GetBidRecDWord( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; var Value: DWORD ): BOOL;                 register;
function  L2_GetBidRecString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL; register;
function  L2_GetExpr( Handle: Pointer; Value: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;            register;
function  L2_GetNAsks( Handle: Pointer ): DWORD;                                                                                   register;
function  L2_GetNBids( Handle: Pointer ): DWORD;                                                                                   register;
function  L2_GetNFields( Handle: Pointer ): DWORD;                                                                                 register;
function  L2_GetSink( Handle: Pointer ): ILevelIISetSink;                                                                          register;
function  L2_GetTitle( Handle: Pointer; Value: PChar; BufferSize: DWORD ): BOOL;                                                   register;
function  L2_Init( Handle: Pointer ): BOOL;                                                                                        register;
procedure L2_LeaveRead( Handle: Pointer );                                                                                         register;
procedure L2_SetSink( Handle: Pointer; Sink: ILevelIISetSink );                                                                    register;

procedure SY_EnterRead( Handle: Pointer );                                                                                   register;
function  SY_GetExpr( Handle: Pointer; Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL; register;
function  SY_GetNFields( Handle: Pointer ): DWORD;                                                                           register;
function  SY_GetNSymbols( Handle: Pointer ): DWORD;                                                                          register;
function  SY_GetSink( Handle: Pointer ): ISymbolSetSink;                                                                     register;
function  SY_GetString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt ): PChar;                                 register;
function  SY_GetTitle( Handle: Pointer; Title: PChar; BufferSize: DWORD ): BOOL;                                             register;
function  SY_Init( Handle: Pointer ): BOOL;                                                                                  register;
procedure SY_LeaveRead( Handle: Pointer );                                                                                   register;
procedure SY_SetSink( Handle: Pointer; Sink: ISymbolSetSink );                                                               register;

procedure TL_EnterRead( Handle: Pointer );                                                   register;
function  TL_GetNFields( Handle: Pointer ): DWORD;                                           register;
function  TL_GetNRecs( Handle: Pointer ): DWORD;                                             register;
function  TL_GetSink( Handle: Pointer ): ITLSetSink;                                         register;
function  TL_GetString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt ): PChar; register;
procedure TL_GetTitle( Handle: Pointer; Title: PChar; BufferSize: DWORD );                   register;
function  TL_Init( Handle: Pointer ): BOOL;                                                  register;
procedure TL_LeaveRead( Handle: Pointer );                                                   register;
procedure TL_SetSink( Handle: Pointer; Sink: ITLSetSink );                                   register;


(* * * * * * * * * * * * * * * * * * *
 *   Continuum Base Exception Type   *
 * * * * * * * * * * * * * * * * * * *)
type
  EContinuumError = class( Exception )
  end;



implementation

{$T-}


type
  PPointer = ^Pointer;


(* * * * * * * * * * * * * * * * * * *
 *       DLL Link Definitions        *
 * * * * * * * * * * * * * * * * * * *)
const
  DLLName = 'ContinuumClient.dll';

const
  DLL_CC_BuildDemoFile_Index          = 1;
  DLL_CC_CheckPermission_Index        = 2;
  DLL_CC_CheckSymbolStatus_Index      = 3;
  DLL_CC_ConnectDirect_Index          = 4;
  DLL_CC_ConnectWindow_Index          = 5;
  DLL_CC_ConnectSink_Index            = 6;
  DLL_CC_CreateLevelIISet_Index       = 7;
  DLL_CC_CreateSnapshotSet_Index      = 8;
  DLL_CC_CreateSymbolSet_Index        = 9;
  DLL_CC_CreateRecordSet_Index        = 10;
  DLL_CC_CreateTopListSet_Index       = 11;
  DLL_CC_DeleteLevelIISet_Index       = 12;
  DLL_CC_DeleteSnapshotSet_Index      = 13;
  DLL_CC_DeleteSymbolSet_Index        = 14;
  DLL_CC_DeleteRecordSet_Index        = 15;
  DLL_CC_DeleteTopListSet_Index       = 16;
  DLL_CC_Disconnect_Index             = 17;
  DLL_CC_EditBASaleRecord_Index       = 18;
  DLL_CC_EditSummaryRecord_Index      = 19;
  DLL_L2_EnterRead_Index              = 20;
  DLL_SS_EnterRead_Index              = 21;
  DLL_SY_EnterRead_Index              = 22;
  DLL_RS_EnterRead_Index              = 23;
  DLL_TL_EnterRead_Index              = 24;
  DLL_SS_FillBuff_Index               = 25;
  DLL_L2_GetAskRecDWord_Index         = 26;
  DLL_L2_GetAskRecString_Index        = 27;
  DLL_RS_GetAutoUpdate_Index          = 28;
  DLL_L2_GetBidRecDWord_Index         = 29;
  DLL_L2_GetBidRecString_Index        = 30;
  DLL_CC_GetBytesInRecvMessageQ_Index = 31;
  DLL_CC_GetConnectionStatus_Index    = 32;
  DLL_SS_GetDWord_Index               = 33;
  DLL_SS_GetDouble_Index              = 34;
  DLL_SS_GetEDate_Index               = 35;
  DLL_RS_GetETime0_Index              = 36;
  DLL_SS_GetETime_Index               = 37;
  DLL_RS_GetETime_Index               = 38;
  DLL_L2_GetExpr_Index                = 39;
  DLL_SS_GetExpr_Index                = 40;
  DLL_SY_GetExpr_Index                = 41;
  DLL_RS_GetExpr_Index                = 42;
  DLL_SS_GetFieldIx_Index             = 43;
  DLL_RS_GetFieldIx_Index             = 44;
  DLL_SS_GetFieldTitle_Index          = 45;
  DLL_RS_GetFieldTitle_Index          = 46;
  DLL_CC_GetHMS_Index                 = 47;
  DLL_RS_GetIndex_Index               = 48;
  DLL_RS_GetIndexingMode_Index        = 49;
  DLL_RS_GetIntervalDWord_Index       = 50;
  DLL_RS_GetIntervalString_Index      = 51;
  DLL_CC_GetLogonResultString_Index   = 52;
  DLL_RS_GetMaxDoubleInField_Index    = 53;
  DLL_RS_GetMaxDoubleInRange_Index    = 54;
  DLL_RS_GetMaxLongInField_Index      = 55;
  DLL_RS_GetMaxLongInRange_Index      = 56;
  DLL_RS_GetMinDoubleInField_Index    = 57;
  DLL_RS_GetMinDoubleInRange_Index    = 58;
  DLL_RS_GetMinLongInField_Index      = 59;
  DLL_RS_GetMinLongInRange_Index      = 60;
  DLL_SS_GetMinutesDelayed_Index      = 61;
  DLL_RS_GetMinutesDelayed_Index      = 62;
  DLL_L2_GetNAsks_Index               = 63;
  DLL_L2_GetNBids_Index               = 64;
  DLL_CC_GetNBytesReceived_Index      = 65;
  DLL_L2_GetNFields_Index             = 66;
  DLL_SY_GetNFields_Index             = 67;
  DLL_TL_GetNFields_Index             = 68;
  DLL_RS_GetNRecs_Index               = 69;
  DLL_TL_GetNRecs_Index               = 70;
  DLL_SY_GetNSymbols_Index            = 71;
  DLL_RS_GetNewExpr_Index             = 72;
  DLL_CC_GetParam_Index               = 73;
  DLL_SS_GetPriceType_Index           = 74;
  DLL_RS_GetPriceType_Index           = 75;
  DLL_RS_GetRecDWord_Index            = 76;
  DLL_RS_GetRecDouble_Index           = 77;
  DLL_RS_GetRecRange_Index            = 78;
  DLL_RS_GetRecString_Index           = 79;
  DLL_CC_GetServerDelay_Index         = 80;
  DLL_CC_GetServerIP_Index            = 81;
  DLL_CC_GetServerName_Index          = 82;
  DLL_CC_GetServerPort_Index          = 83;
  DLL_CC_GetServerTime_Index          = 84;
  DLL_L2_GetSink_Index                = 85;
  DLL_SS_GetSink_Index                = 86;
  DLL_SY_GetSink_Index                = 87;
  DLL_RS_GetSink_Index                = 88;
  DLL_TL_GetSink_Index                = 89;
  DLL_CC_GetStats_Index               = 90;
  DLL_SY_GetString_Index              = 91;
  DLL_TL_GetString_Index              = 92;
  DLL_SS_GetSymbolStatus_Index        = 93;
  DLL_L2_GetTitle_Index               = 94;
  DLL_SS_GetTitle_Index               = 95;
  DLL_SY_GetTitle_Index               = 96;
  DLL_RS_GetTitle_Index               = 97;
  DLL_TL_GetTitle_Index               = 98;
  DLL_CC_GetUserName_Index            = 99;
  DLL_CC_GetUserPassword_Index        = 100;
  DLL_CC_GetYMD_Index                 = 101;
  DLL_L2_Init_Index                   = 102;
  DLL_SS_Init_Index                   = 103;
  DLL_SY_Init_Index                   = 104;
  DLL_RS_Init_Index                   = 105;
  DLL_TL_Init_Index                   = 106;
  DLL_SS_IsRequestPending_Index       = 107;
  DLL_RS_IsRequestPending_Index       = 108;
  DLL_L2_LeaveRead_Index              = 109;
  DLL_SS_LeaveRead_Index              = 110;
  DLL_SY_LeaveRead_Index              = 111;
  DLL_RS_LeaveRead_Index              = 112;
  DLL_TL_LeaveRead_Index              = 113;
  DLL_CC_MakeTime_Index               = 114;
  DLL_CC_NextServer_Index             = 115;
  DLL_CC_PriceToBuff_Index            = 116;
  DLL_SS_RetDWord_Index               = 117;
  DLL_SS_RetDouble_Index              = 118;
  DLL_RS_Scroll_Index                 = 119;
  DLL_CC_SendLogon_Index              = 120;
  DLL_RS_SetAutoUpdate_Index          = 121;
  DLL_RS_SetIndexingMode_Index        = 122;
  DLL_RS_SetNRecs_Index               = 123;
  DLL_CC_SetNotificationWnd_Index     = 124;
  DLL_CC_SetParam_Index               = 125;
  DLL_L2_SetSink_Index                = 126;
  DLL_SS_SetSink_Index                = 127;
  DLL_SY_SetSink_Index                = 128;
  DLL_RS_SetSink_Index                = 129;
  DLL_TL_SetSink_Index                = 130;
  DLL_CC_SetTimer_Index               = 131;
  DLL_CC_SetUserMode_Index            = 132;
  DLL_CC_Shutdown_Index               = 133;
  DLL_pContinuumClient_Index          = 134;



(* * * * * * * * * * * * * * * * * * *
 *  Reference to C++ client global   *
 * * * * * * * * * * * * * * * * * * *)
var
  DLL_ContinuumClient: Pointer;


// Handle isn't really a function, but actually a data pointer. Don't try to call it!
// A bit of "Microsoft Magic" going on here. Note that we don't really need this
// pointer for anything; obtaining it is just a formality in case someday they
// change things so that we do need it.
procedure pContinuumClient;
          stdcall; external DLLName  Index DLL_pContinuumClient_Index;


(* * * * * * * * * * * * * * * * * * *
 *    ContinuumClient Externals      *
 * * * * * * * * * * * * * * * * * * *)

procedure DLL_CC_BuildDemoFile( ScriptFile: PChar );
          stdcall; external DLLName Index DLL_CC_BuildDemoFile_Index;
function  DLL_CC_CheckPermission( Permission: PChar ): Byte;
          stdcall; external DLLName Index DLL_CC_CheckPermission_Index;
function  DLL_CC_CheckSymbolStatus( Symbol: PChar ): SHORT;
          stdcall; external DLLName Index DLL_CC_CheckSymbolStatus_Index;
function  DLL_CC_ConnectDirect( UserName: PChar; Password: PChar; Timeout: DWORD ): ShortInt;
          stdcall; external DLLName Index DLL_CC_ConnectDirect_Index;
function  DLL_CC_ConnectSink( Sink: Pointer ): BOOL;
          stdcall; external DLLName Index 6;
function  DLL_CC_ConnectWindow( Window: HWND ): BOOL;
          stdcall; external DLLName Index DLL_CC_ConnectWindow_Index;
function  DLL_CC_CreateRecordSet( Expression: PChar ): Pointer;
          stdcall; external DLLName Index DLL_CC_CreateRecordSet_Index;
function  DLL_CC_CreateSnapshotSet( Expression: PChar ): Pointer;
          stdcall; external DLLName Index DLL_CC_CreateSnapshotSet_Index;
function  DLL_CC_CreateTopListSet( Expression: PChar ): Pointer;
          stdcall; external DLLName Index DLL_CC_CreateTopListSet_Index;
function  DLL_CC_CreateLevelIISet( Expression: PChar ): Pointer;
          stdcall; external DLLName Index DLL_CC_CreateLevelIISet_Index;
function  DLL_CC_CreateSymbolSet( Expression: PChar ): Pointer;
          stdcall; external DLLName Index DLL_CC_CreateSymbolSet_Index;
procedure DLL_CC_DeleteRecordSet( RecordSet: Pointer );
          stdcall; external DLLName Index DLL_CC_DeleteRecordSet_Index;
procedure DLL_CC_DeleteSnapshotSet( SnapshotSet: Pointer );
          stdcall; external DLLName Index DLL_CC_DeleteSnapshotSet_Index;
procedure DLL_CC_DeleteTopListSet( TopListSet: Pointer );
          stdcall; external DLLName Index DLL_CC_DeleteTopListSet_Index;
procedure DLL_CC_DeleteLevelIISet( LevelIISet: Pointer );
          stdcall; external DLLName Index DLL_CC_DeleteLevelIISet_Index;
procedure DLL_CC_DeleteSymbolSet( SymbolSet: Pointer );
          stdcall; external DLLName Index DLL_CC_DeleteSymbolSet_Index;
procedure DLL_CC_Disconnect;
          stdcall; external DLLName Index 17;
procedure DLL_CC_EditBASaleRecord( psz: PChar; Action: Byte; Data: Pointer );
          stdcall; external DLLName Index DLL_CC_EditBASaleRecord_Index;
procedure DLL_CC_EditSummaryRecord( psz: PChar; Action: Byte; Data: Pointer );
          stdcall; external DLLName Index DLL_CC_EditSummaryRecord_Index;
function  DLL_CC_GetBytesInRecvMessageQ: DWORD;
          stdcall; external DLLName Index DLL_CC_GetBytesInRecvMessageQ_Index;
function  DLL_CC_GetConnectionStatus: LongInt;
          stdcall; external DLLName Index DLL_CC_GetConnectionStatus_Index;
procedure DLL_CC_GetHMS( ETime: DWORD; var Hour: DWORD; var Minute: DWORD; var Second: DWORD );
          stdcall; external DLLName Index DLL_CC_GetHMS_Index;
function  DLL_CC_GetLogonResultString: PChar;
          stdcall; external DLLName Index DLL_CC_GetLogonResultString_Index;
function  DLL_CC_GetNBytesReceived: DWORD;
          stdcall; external DLLName Index DLL_CC_GetNBytesReceived_Index;
function  DLL_CC_GetParam( Index: LongInt ): DWORD;
          stdcall; external DLLName Index DLL_CC_GetParam_Index;
function  DLL_CC_GetServerDelay: DWORD;
          stdcall; external DLLName Index DLL_CC_GetServerDelay_Index;
function  DLL_CC_GetServerIP: DWORD;
          stdcall; external DLLName Index DLL_CC_GetServerIP_Index;
function  DLL_CC_GetServerName: PChar;
          stdcall; external DLLName Index DLL_CC_GetServerName_Index;
function  DLL_CC_GetServerPort: Word;
          stdcall; external DLLName Index DLL_CC_GetServerPort_Index;
procedure DLL_CC_GetServerTime( var SystemTime: SYSTEMTIME );
          stdcall; external DLLName Index DLL_CC_GetServerTime_Index;
function  DLL_CC_GetStats( Buffer: PChar; BufferSize: LongInt ): BOOL;
          stdcall; external DLLName Index DLL_CC_GetStats_Index;
function  DLL_CC_GetUserName: PChar;
          stdcall; external DLLName Index DLL_CC_GetUserName_Index;
function  DLL_CC_GetUserPassword( Encrypted: BOOL ): PChar;
          stdcall; external DLLName Index DLL_CC_GetUserPassword_Index;
procedure DLL_CC_GetYMD( ETime: DWORD; var Year: DWORD; var Month:  DWORD; var Day:    DWORD );
          stdcall; external DLLName Index DLL_CC_GetYMD_Index;
function  DLL_CC_MakeTime(Year: DWORD; Month:  DWORD; Day: DWORD; Hour: DWORD; Minute: DWORD; Second: DWORD ): DWORD;
          stdcall; external DLLName Index DLL_CC_MakeTime_Index;
procedure DLL_CC_NextServer;
          stdcall; external DLLName Index DLL_CC_NextServer_Index;
procedure DLL_CC_PriceToBuff(Price: DWORD; PriceType: Byte; Buffer: PChar; BufferSize: LongInt );
          stdcall; external DLLName Index DLL_CC_PriceToBuff_Index;
procedure DLL_CC_SendLogon( UserName: PChar; Password: PChar );
          stdcall; external DLLName Index DLL_CC_SendLogon_Index;
procedure DLL_CC_SetNotificationWnd( Window: HWND );
          stdcall; external DLLName Index DLL_CC_SetNotificationWnd_Index;
procedure DLL_CC_SetParam( Index: LongInt; Value: DWORD );
          stdcall; external DLLName Index DLL_CC_SetParam_Index;
procedure DLL_CC_SetUserMode( Mode: LongInt );
          stdcall; external DLLName Index DLL_CC_SetUserMode_Index;
function  DLL_CC_SetTimer( Interval: DWORD ): DWORD;
          stdcall; external DLLName Index DLL_CC_SetTimer_Index;
procedure DLL_CC_Shutdown;
          stdcall; external DLLName Index DLL_CC_Shutdown_Index;


(* * * * * * * * * * * * * * * * * * *
 *       TRecordSet Externals        *
 * * * * * * * * * * * * * * * * * * *)

function  DLL_RS_GetAutoUpdate: DWORD;
          stdcall; external DLLName Index DLL_RS_GetAutoUpdate_Index;
function  DLL_RS_GetETime( Index: DWORD; Flag: DWORD; var ETime: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetETime_Index;
function  DLL_RS_GetETime0: DWORD;
          stdcall; external DLLName Index DLL_RS_GetETime0_Index;
function  DLL_RS_GetExpr( Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetExpr_Index;
function  DLL_RS_GetFieldIx( Field: PChar ): DWORD;
          stdcall; external DLLName Index DLL_RS_GetFieldIx_Index;
function  DLL_RS_GetFieldTitle( FieldIndex: LongInt; Title: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetFieldTitle_Index;
function  DLL_RS_GetIndex( ETime: DWORD; var Estimate: BOOL ): DWORD;
          stdcall; external DLLName Index DLL_RS_GetIndex_Index;
function  DLL_RS_GetIndexingMode: BOOL;
          stdcall; external DLLName Index DLL_RS_GetIndexingMode_Index;
function  DLL_RS_GetIntervalDWord: DWORD;
          stdcall; external DLLName Index DLL_RS_GetIntervalDWord_Index;
function  DLL_RS_GetIntervalString( Output: PChar; BufferSize: DWORD; User: BOOL ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetIntervalString_Index;
function  DLL_RS_GetMaxDoubleInField( Index: LongInt ): Double;
          stdcall; external DLLName Index DLL_RS_GetMaxDoubleInField_Index;
function  DLL_RS_GetMaxDoubleInRange( StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): Double;
          stdcall; external DLLName Index DLL_RS_GetMaxDoubleInRange_Index;
function  DLL_RS_GetMaxLongInField( Index: LongInt ): LongInt;
          stdcall; external DLLName Index DLL_RS_GetMaxLongInField_Index;
function  DLL_RS_GetMaxLongInRange( StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): LongInt;
          stdcall; external DLLName Index DLL_RS_GetMaxLongInRange_Index;
function  DLL_RS_GetMinDoubleInField( Index: LongInt ): Double;
          stdcall; external DLLName Index DLL_RS_GetMinDoubleInField_Index;
function  DLL_RS_GetMinDoubleInRange( StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): Double;
          stdcall; external DLLName Index DLL_RS_GetMinDoubleInRange_Index;
function  DLL_RS_GetMinLongInField( Index: LongInt ): LongInt;
          stdcall; external DLLName Index DLL_RS_GetMinLongInField_Index;
function  DLL_RS_GetMinLongInRange( StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): LongInt;
          stdcall; external DLLName Index DLL_RS_GetMinLongInRange_Index;
function  DLL_RS_GetMinutesDelayed: DWORD;
          stdcall; external DLLName Index DLL_RS_GetMinutesDelayed_Index;
function  DLL_RS_GetNewExpr( Expression: PChar; BufferSize: DWORD; Base: PChar ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetNewExpr_Index;
function  DLL_RS_GetNRecs: DWORD;
          stdcall; external DLLName Index DLL_RS_GetNRecs_Index;
function  DLL_RS_GetPriceType( FieldIndex: LongInt ): DWORD;
          stdcall; external DLLName Index DLL_RS_GetPriceType_Index;
function  DLL_RS_GetRecDWord( RecordIndex: LongInt; FieldIndex: LongInt; var Value: LongInt ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetRecDWord_Index;
function  DLL_RS_GetRecDouble( RecordIndex: LongInt; FieldIndex: LongInt; var Value: Double ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetRecDouble_Index;
function  DLL_RS_GetRecRange( var StartIndex: LongInt; var EndIndex: LongInt ): DWORD;
          stdcall; external DLLName Index DLL_RS_GetRecRange_Index;
function  DLL_RS_GetRecString( RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetRecString_Index;
function  DLL_RS_GetSink: Pointer;
          stdcall; external DLLName Index DLL_RS_GetSink_Index;
function  DLL_RS_GetTitle( Title: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_RS_GetTitle_Index;
procedure DLL_RS_EnterRead;
          stdcall; external DLLName Index DLL_RS_EnterRead_Index;
function  DLL_RS_Init( RecordCount: DWORD; StartTime: DWORD ): LongInt;
          stdcall; external DLLName Index DLL_RS_Init_Index;
function  DLL_RS_IsRequestPending: BOOL;
          stdcall; external DLLName Index DLL_RS_IsRequestPending_Index;
procedure DLL_RS_LeaveRead;
          stdcall; external DLLName Index DLL_RS_LeaveRead_Index;
procedure DLL_RS_Scroll( ScrollBy: LongInt; RequestData: BOOL );
          stdcall; external DLLName Index DLL_RS_Scroll_Index;
procedure DLL_RS_SetAutoUpdate( AutoUpdateMode: DWORD );
          stdcall; external DLLName Index DLL_RS_SetAutoUpdate_Index;
procedure DLL_RS_SetIndexingMode( Relative: BOOL );
          stdcall; external DLLName Index DLL_RS_SetIndexingMode_Index;
procedure DLL_RS_SetSink( Sink: Pointer );
          stdcall; external DLLName Index DLL_RS_SetSink_Index;
function  DLL_RS_SetNRecs( NewQuantity: DWORD; AnchorZ: BOOL ): LongInt;
          stdcall; external DLLName Index DLL_RS_SetNRecs_Index;


(* * * * * * * * * * * * * * * * * * *
 *       SnapShotSet Externals       *
 * * * * * * * * * * * * * * * * * * *)

procedure DLL_SS_EnterRead;
          stdcall; external DLLName Index DLL_SS_EnterRead_Index;
function  DLL_SS_FillBuff( FieldIndex: LongInt; Buffer: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_SS_FillBuff_Index;
function  DLL_SS_GetDouble( FieldIndex: LongInt; var Value: Double ): BOOL;
          stdcall; external DLLName Index DLL_SS_GetDouble_Index;
function  DLL_SS_GetDWord( FieldIndex: LongInt; var Value: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_SS_GetDWord_Index;
function  DLL_SS_GetEDate: DWORD;
          stdcall; external DLLName Index DLL_SS_GetEDate_Index;
function  DLL_SS_GetETime: DWORD;
          stdcall; external DLLName Index DLL_SS_GetETime_Index;
function  DLL_SS_GetExpr( Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_SS_GetExpr_Index;
function  DLL_SS_GetFieldIx( Field: PChar ): LongInt;
          stdcall; external DLLName Index DLL_SS_GetFieldIx_Index;
function  DLL_SS_GetFieldTitle( FieldIndex: LongInt; Title: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_SS_GetFieldTitle_Index;
function  DLL_SS_GetMinutesDelayed: DWORD;
          stdcall; external DLLName Index DLL_SS_GetMinutesDelayed_Index;
function  DLL_SS_GetPriceType( FieldIndex: LongInt ): DWORD;
          stdcall; external DLLName Index DLL_SS_GetPriceType_Index;
function  DLL_SS_GetSink: Pointer;
          stdcall; external DLLName Index DLL_SS_GetSink_Index;
function  DLL_SS_GetSymbolStatus: LongInt;
          stdcall; external DLLName Index DLL_SS_GetSymbolStatus_Index;
function  DLL_SS_GetTitle( Title: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_SS_GetTitle_Index;
function  DLL_SS_Init: BOOL;
          stdcall; external DLLName Index DLL_SS_Init_Index;
function  DLL_SS_IsRequestPending: BOOL;
          stdcall; external DLLName Index DLL_SS_IsRequestPending_Index;
procedure DLL_SS_LeaveRead;
          stdcall; external DLLName Index DLL_SS_LeaveRead_Index;
function  DLL_SS_RetDouble( FieldIndex: LongInt ): Double;
          stdcall; external DLLName Index DLL_SS_RetDouble_Index;
function  DLL_SS_RetDWord( FieldIndex: LongInt ): DWORD;
          stdcall; external DLLName Index DLL_SS_RetDWord_Index;
procedure DLL_SS_SetSink( Sink: Pointer );
          stdcall; external DLLName Index DLL_SS_SetSink_Index;


(* * * * * * * * * * * * * * * * * * *
 *        Level2Set Externals        *
 * * * * * * * * * * * * * * * * * * *)

procedure DLL_L2_EnterRead;
          stdcall; external DLLName Index DLL_L2_EnterRead_Index;
function  DLL_L2_GetAskRecDWord( RecordIndex: LongInt; FieldIndex: LongInt; var Value: LongInt ): BOOL;
          stdcall; external DLLName Index DLL_L2_GetAskRecDWord_Index;
function  DLL_L2_GetAskRecString( RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_L2_GetAskRecString_Index;
function  DLL_L2_GetBidRecDWord( RecordIndex: LongInt; FieldIndex: LongInt; var Value: LongInt ): BOOL;
          stdcall; external DLLName Index DLL_L2_GetBidRecDWord_Index;
function  DLL_L2_GetBidRecString( RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_L2_GetBidRecString_Index;
function  DLL_L2_GetExpr( Value: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_L2_GetExpr_Index;
function  DLL_L2_GetNAsks: DWORD;
          stdcall; external DLLName Index DLL_L2_GetNAsks_Index;
function  DLL_L2_GetNBids: DWORD;
          stdcall; external DLLName Index DLL_L2_GetNBids_Index;
function  DLL_L2_GetNFields: DWORD;
          stdcall; external DLLName Index DLL_L2_GetNFields_Index;
function  DLL_L2_GetSink: Pointer;
          stdcall; external DLLName Index DLL_L2_GetSink_Index;
function  DLL_L2_GetTitle( Value: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_L2_GetTitle_Index;
function  DLL_L2_Init: BOOL;
          stdcall; external DLLName Index DLL_L2_Init_Index;
procedure DLL_L2_LeaveRead;
          stdcall; external DLLName Index DLL_L2_LeaveRead_Index;
procedure DLL_L2_SetSink( Sink: Pointer );
          stdcall; external DLLName Index DLL_L2_SetSink_Index;


(* * * * * * * * * * * * * * * * * * *
 *        TopListSet Externals       *
 * * * * * * * * * * * * * * * * * * *)

function  DLL_TL_Init: BOOL;
          stdcall; external DLLName Index DLL_TL_Init_Index;
procedure DLL_TL_EnterRead;
          stdcall; external DLLName Index DLL_TL_EnterRead_Index;
procedure DLL_TL_LeaveRead;
          stdcall; external DLLName Index DLL_TL_LeaveRead_Index;
procedure DLL_TL_SetSink( Sink: Pointer );
          stdcall; external DLLName Index DLL_TL_SetSink_Index;
function  DLL_TL_GetSink: Pointer;
          stdcall; external DLLName Index DLL_TL_GetSink_Index;
function  DLL_TL_GetString( RecordIndex: LongInt; FieldIndex: LongInt ): PChar;
          stdcall; external DLLName Index DLL_TL_GetString_Index;
function  DLL_TL_GetNRecs: DWORD;
          stdcall; external DLLName Index DLL_TL_GetNRecs_Index;
function  DLL_TL_GetNFields: DWORD;
          stdcall; external DLLName Index DLL_TL_GetNFields_Index;
procedure DLL_TL_GetTitle( Title: PChar; BufferSize: DWORD );
          stdcall; external DLLName Index DLL_TL_GetTitle_Index;


(* * * * * * * * * * * * * * * * * * *
 *        SymbolSet Externals        *
 * * * * * * * * * * * * * * * * * * *)

function  DLL_SY_Init: BOOL;
          stdcall; external DLLName Index DLL_SY_Init_Index;
procedure DLL_SY_EnterRead;
          stdcall; external DLLName Index DLL_SY_EnterRead_Index;
procedure DLL_SY_LeaveRead;
          stdcall; external DLLName Index DLL_SY_LeaveRead_Index;
procedure DLL_SY_SetSink( Sink: Pointer );
          stdcall; external DLLName Index DLL_SY_SetSink_Index;
function  DLL_SY_GetSink: Pointer;
          stdcall; external DLLName Index DLL_SY_GetSink_Index;
function  DLL_SY_GetString( RecordIndex: LongInt; FieldIndex: LongInt ): PChar;
          stdcall; external DLLName Index DLL_SY_GetString_Index;
function  DLL_SY_GetNSymbols: DWORD;
          stdcall; external DLLName Index DLL_SY_GetNSymbols_Index;
function  DLL_SY_GetNFields: DWORD;
          stdcall; external DLLName Index DLL_SY_GetNFields_Index;
function  DLL_SY_GetTitle( Title: PChar; BufferSize: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_SY_GetTitle_Index;
function  DLL_SY_GetExpr( Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;
          stdcall; external DLLName Index DLL_SY_GetExpr_Index;

(* * * * * * * * * * * * * * * * * * *
 *     ContinuumClient Wrappers      *
 * * * * * * * * * * * * * * * * * * *)

// Note that we do not move the "Handle" pointer into ECX as the Handlecall calling convention technically
// requires. Handle is because the ContinuumClient object has no data members, and no virtual functions
// and thus no vtable. Hence, the pointer doesn't really point to anything at all, just a zero-size
// allocation on the heap. Since "Handle" will never be dereferenced, why bother supplying it? If Handle
// changes later, we can easily stick it back in.

procedure CC_BuildDemoFile( ScriptFile: PChar );
asm
  push ScriptFile
  call DLL_CC_BuildDemoFile
end;

function CC_CheckPermission( Permission: PChar ): DWORD;
asm
  push Permission
  call DLL_CC_CheckPermission
end;

function CC_CheckSymbolStatus( Symbol: PChar ): ShortInt;
asm
  push Symbol
  call DLL_CC_CheckSymbolStatus
end;

function CC_ConnectDirect( UserName: PChar; Password: PChar; Timeout: DWORD ): ShortInt;
asm
  push Timeout
  push Password
  push UserName
  call DLL_CC_ConnectDirect
end;

function CC_ConnectSink( Sink: EConnectStatus ): BOOL;
asm
  mov  ECX, Sink
  add  ECX, OFFSET Sink.FSinkMockup
  push ECX
  call DLL_CC_ConnectSink
end;

function CC_ConnectWindow( Window: HWND ): BOOL;
asm
  push Window
  call DLL_CC_ConnectWindow
end;

function CC_CreateRecordSet( Expression: PChar ): Pointer;
asm
  push Expression
  call DLL_CC_CreateRecordSet
end;

function CC_CreateSnapshotSet( Expression: PChar ): Pointer;
asm
  push Expression
  call DLL_CC_CreateSnapshotSet
end;

function CC_CreateTopListSet( Expression: PChar ): Pointer;
asm
  push Expression
  call DLL_CC_CreateTopListSet
end;

function CC_CreateLevelIISet( Expression: PChar ): Pointer;
asm
  push Expression
  call DLL_CC_CreateLevelIISet
end;

function CC_CreateSymbolSet( Expression: PChar ): Pointer;
asm
  push Expression
  call DLL_CC_CreateSymbolSet
end;

procedure CC_DeleteRecordSet( RecordSet: Pointer );
asm
  push RecordSet
  call DLL_CC_DeleteRecordSet
end;

procedure CC_DeleteSnapshotSet( SnapshotSet: Pointer );
asm
  push SnapshotSet
  call DLL_CC_DeleteSnapshotSet
end;

procedure CC_DeleteTopListSet( TopListSet: Pointer );
asm
  push TopListSet
  call DLL_CC_DeleteTopListSet
end;

procedure CC_DeleteLevelIISet( LevelIISet: Pointer );
asm
  push LevelIISet
  call DLL_CC_DeleteLevelIISet
end;

procedure CC_DeleteSymbolSet( SymbolSet: Pointer );
asm
  push SymbolSet
  call DLL_CC_DeleteSymbolSet
end;

procedure CC_Disconnect;
asm
  call DLL_CC_Disconnect
end;

procedure CC_EditBASaleRecord( psz: PChar; Action: DWORD; Data: Pointer );
asm
  push Data
  push Action
  push psz
  call DLL_CC_EditBASaleRecord
end;

procedure CC_EditSummaryRecord( psz: PChar; Action: DWORD; Data: Pointer );
asm
  push Data
  push Action
  push psz
  call DLL_CC_EditSummaryRecord
end;

function CC_GetBytesInRecvMessageQ: DWORD;
asm
  call DLL_CC_GetBytesInRecvMessageQ
end;

function CC_GetConnectionStatus: LongInt;
asm
  call DLL_CC_GetConnectionStatus
end;

procedure CC_GetHMS( ETime: DWORD; var Hour: DWORD; var Minute: DWORD; var Second: DWORD );
asm
  push Second
  push Minute
  push Hour
  push ETime
  call DLL_CC_GetHMS
end;

function CC_GetLogonResultString: PChar;
asm
  call DLL_CC_GetLogonResultString
end;

function CC_GetNBytesReceived: DWORD;
asm
  call DLL_CC_GetNBytesReceived
end;

function CC_GetParam( Index: LongInt ): DWORD;
asm
  push Index
  call DLL_CC_GetParam
end;

function CC_GetServerDelay: DWORD;
asm
  call DLL_CC_GetServerDelay
end;

function CC_GetServerIP: DWORD;
asm
  call DLL_CC_GetServerIP
end;

function CC_GetServerName: PChar;
asm
  call DLL_CC_GetServerName
end;

function CC_GetServerPort: Word;
asm
  call DLL_CC_GetServerPort
end;

procedure CC_GetServerTime( var SystemTime: SYSTEMTIME );
asm
  push SystemTime
  call DLL_CC_GetServerTime
end;

function CC_GetStats( Buffer: PChar; BufferSize: LongInt ): BOOL;
asm
  push BufferSize
  push Buffer
  call DLL_CC_GetStats
end;

function CC_GetUserName: PChar;
asm
  call DLL_CC_GetUserName
end;

function CC_GetUserPassword( Encrypted: BOOL ): PChar;
asm
  push Encrypted
  call DLL_CC_GetUserPassword
end;

procedure CC_GetYMD( ETime: DWORD; var Year: DWORD; var Month: DWORD; var Day: DWORD );
asm
  push Day
  push Month
  push Year
  push ETime
  call DLL_CC_GetYMD
end;

function CC_MakeTime(Year: DWORD; Month:  DWORD; Day: DWORD; Hour: DWORD; Minute: DWORD; Second: DWORD ): DWORD;
asm
  push Second
  push Minute
  push Hour
  push Day
  push Month
  push Year
  call DLL_CC_MakeTime
end;

procedure CC_NextServer;
asm
  call DLL_CC_NextServer
end;

procedure CC_PriceToBuff(Price: DWORD; PriceType: DWORD; Buffer: PChar; BufferSize: LongInt );
asm
  push BufferSize
  push Buffer
  push PriceType
  push Price
  call DLL_CC_PriceToBuff
end;

procedure CC_SendLogon( UserName: PChar; Password: PChar );
asm
  push Password
  push UserName
  call DLL_CC_SendLogon
end;

procedure CC_SetNotificationWnd( Window: HWND );
asm
  push Window
  call DLL_CC_SetNotificationWnd
end;

procedure CC_SetParam( Index: LongInt; Value: DWORD );
asm
  push Value
  push Index
  call DLL_CC_SetParam
end;

procedure CC_SetUserMode( Mode: LongInt );
asm
  push Mode
  call DLL_CC_SetUserMode
end;

function CC_SetTimer( Interval: DWORD ): DWORD;
asm
  push Interval
  call DLL_CC_SetTimer
end;

procedure CC_Shutdown;
asm
  mov  ECX, DLL_ContinuumClient
  call DLL_CC_Shutdown
end;


(* * * * * * * * * * * * * * * * * * *
 *       TRecordSet Wrappers         *
 * * * * * * * * * * * * * * * * * * *)

function RS_GetAutoUpdate( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_RS_GetAutoUpdate
end;

function RS_GetETime( Handle: Pointer; Index: DWORD; Flag: DWORD; var ETime: DWORD ): BOOL;
asm
  push ETime
  push Flag
  push Index
  mov  ECX, Handle
  call DLL_RS_GetETime
end;

function RS_GetETime0( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_RS_GetETime0
end;

function RS_GetExpr( Handle: Pointer; Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;
asm
  push Permissions
  push Internal
  push BufferSize
  push Expression
  mov  ECX, Handle
  call DLL_RS_GetExpr
end;

function RS_GetFieldIx( Handle: Pointer; Field: PChar ): SmallInt;
asm
  push Field
  mov  ECX, Handle
  call DLL_RS_GetFieldIx
end;

function RS_GetFieldTitle( Handle: Pointer; FieldIndex: LongInt; Title: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Title
  push FieldIndex
  mov  ECX, Handle
  call DLL_RS_GetFieldTitle
end;

function RS_GetIndex( Handle: Pointer; ETime: DWORD; var Estimate: BOOL ): DWORD;
asm
  push Estimate
  push ETime
  mov  ECX, Handle
  call DLL_RS_GetIndex
end;

function RS_GetIndexingMode( Handle: Pointer ): BOOL;
asm
  mov  ECX, Handle
  call DLL_RS_GetIndexingMode
end;

function RS_GetIntervalDWord( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_RS_GetIntervalDWord
end;

function RS_GetIntervalString( Handle: Pointer; Output: PChar; BufferSize: DWORD; User: BOOL ): BOOL;
asm
  push User
  push BufferSize
  push Output
  mov  ECX, Handle
  call DLL_RS_GetIntervalString
end;

function RS_GetMaxDoubleInField( Handle: Pointer; Index: LongInt ): Double;
asm
  push Index
  mov  ECX, Handle
  call DLL_RS_GetMaxDoubleInField
end;

function RS_GetMaxDoubleInRange( Handle: Pointer; StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): Double;
asm
  push FieldIndex
  push EndIndex
  push StartIndex
  mov  ECX, Handle
  call DLL_RS_GetMaxDoubleInRange
end;

function RS_GetMaxLongInField( Handle: Pointer; Index: LongInt ): DWORD;
asm
  push Index
  mov  ECX, Handle
  call DLL_RS_GetMaxLongInField
end;

function RS_GetMaxLongInRange( Handle: Pointer; StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): DWORD;
asm
  push FieldIndex
  push EndIndex
  push StartIndex
  mov  ECX, Handle
  call DLL_RS_GetMaxLongInRange
end;

function RS_GetMinDoubleInField( Handle: Pointer; Index: LongInt ): Double;
asm
  push Index
  mov  ECX, Handle
  call DLL_RS_GetMinDoubleInField
end;

function RS_GetMinDoubleInRange( Handle: Pointer; StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): Double;
asm
  push FieldIndex
  push EndIndex
  push StartIndex
  mov  ECX, Handle
  call DLL_RS_GetMinDoubleInRange
end;

function RS_GetMinLongInField( Handle: Pointer; Index: LongInt ): DWORD;
asm
  push Index
  mov  ECX, Handle
  call DLL_RS_GetMinLongInField
end;

function RS_GetMinLongInRange( Handle: Pointer; StartIndex: LongInt; EndIndex: LongInt; FieldIndex: LongInt ): DWORD;
asm
  push FieldIndex
  push EndIndex
  push StartIndex
  mov  ECX, Handle
  call DLL_RS_GetMinLongInRange
end;

function RS_GetMinutesDelayed( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_RS_GetMinutesDelayed
end;

function RS_GetNewExpr( Handle: Pointer; Expression: PChar; BufferSize: DWORD; Base: PChar ): BOOL;
asm
  push Base
  push BufferSize
  push Expression
  mov  ECX, Handle
  call DLL_RS_GetNewExpr
end;

function RS_GetNRecs( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_RS_GetNRecs
end;

function RS_GetPriceType( Handle: Pointer; FieldIndex: LongInt ): Byte;
asm
  push FieldIndex
  mov  ECX, Handle
  call DLL_RS_GetPriceType
end;

function RS_GetRecDWord( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; var Value: DWORD ): BOOL;
asm
  push Value
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_RS_GetRecDWord
end;

function RS_GetRecDouble( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; var Value: Double ): BOOL;
asm
  push Value
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_RS_GetRecDouble
end;

function RS_GetRecRange( Handle: Pointer; var StartIndex: LongInt; var EndIndex: LongInt ): DWORD;
asm
  push EndIndex
  push StartIndex
  mov  ECX, Handle
  call DLL_RS_GetRecRange
end;

function RS_GetRecString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Value
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_RS_GetRecString
end;

function RS_GetSink( Handle: Pointer ): ITRecSetSink;
asm
  mov  ECX, Handle
  call DLL_RS_GetSink
  mov  EAX, TSinkMockup( [EAX] ).SinkObject
end;

function RS_GetTitle( Handle: Pointer; Title: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Title
  mov  ECX, Handle
  call DLL_RS_GetTitle
end;

procedure RS_EnterRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_RS_EnterRead
end;

function RS_Init( Handle: Pointer; RecordCount: DWORD; StartTime: DWORD ): LongInt;
asm
  push StartTime
  push RecordCount
  mov  ECX, Handle
  call DLL_RS_Init
end;

function RS_IsRequestPending( Handle: Pointer ): BOOL;
asm
  mov  ECX, Handle
  call DLL_RS_IsRequestPending
end;

procedure RS_LeaveRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_RS_LeaveRead
end;

procedure RS_Scroll( Handle: Pointer; ScrollBy: LongInt; RequestData: BOOL );
asm
  push RequestData
  push ScrollBy
  mov  ECX, Handle
  call DLL_RS_Scroll
end;

procedure RS_SetAutoUpdate( Handle: Pointer; AutoUpdateMode: DWORD );
asm
  push AutoUpdateMode
  mov  ECX, Handle
  call DLL_RS_SetAutoUpdate
end;

procedure RS_SetIndexingMode( Handle: Pointer; Relative: BOOL );
asm
  push Relative
  mov  ECX, Handle
  call DLL_RS_SetIndexingMode
end;

procedure RS_SetSink( Handle: Pointer; Sink: ITRecSetSink );
asm
  mov  ECX, Sink
  add  ECX, OFFSET Sink.FSinkMockup
  push ECX
  mov  ECX, Handle
  call DLL_RS_SetSink
end;

function RS_SetNRecs( Handle: Pointer; NewQuantity: DWORD; AnchorZ: BOOL ): LongInt;
asm
  push AnchorZ
  push NewQuantity
  mov  ECX, Handle
  call DLL_RS_SetNRecs
end;


(* * * * * * * * * * * * * * * * * * *
 *      SnapshotSet Wrappers         *
 * * * * * * * * * * * * * * * * * * *)

procedure SS_EnterRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_SS_EnterRead
end;

function SS_FillBuff( Handle: Pointer; FieldIndex: LongInt; Buffer: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Buffer
  push FieldIndex
  mov  ECX, Handle
  call DLL_SS_FillBuff
end;

function SS_GetDouble( Handle: Pointer; FieldIndex: LongInt; var Value: Double ): BOOL;
asm
  push Value
  push FieldIndex
  mov  ECX, Handle
  call DLL_SS_GetDouble
end;

function SS_GetDWord( Handle: Pointer; FieldIndex: LongInt; var Value: DWORD ): BOOL;
asm
  push Value
  push FieldIndex
  mov  ECX, Handle
  call DLL_SS_GetDWord
end;

function SS_GetEDate( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_SS_GetEDate
end;

function SS_GetETime( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_SS_GetETime
end;

function SS_GetExpr( Handle: Pointer; Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;
asm
  push Permissions
  push Internal
  push BufferSize
  push Expression
  mov  ECX, Handle
  call DLL_SS_GetExpr
end;

function SS_GetFieldIx( Handle: Pointer; Field: PChar ): LongInt;
asm
  push Field
  mov  ECX, Handle
  call DLL_SS_GetFieldIx
end;

function SS_GetFieldTitle( Handle: Pointer; FieldIndex: LongInt; Title: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Title
  push FieldIndex
  mov  ECX, Handle
  call DLL_SS_GetFieldTitle
end;

function SS_GetMinutesDelayed( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_SS_GetMinutesDelayed
end;

function SS_GetPriceType( Handle: Pointer; FieldIndex: LongInt ): DWORD;
asm
  push FieldIndex
  mov  ECX, Handle
  call DLL_SS_GetPriceType
end;

function SS_GetSink( Handle: Pointer ): ISSSetSink;
asm
  mov  ECX, Handle
  call DLL_SS_GetSink
  mov  EAX, TSinkMockup( [EAX] ).SinkObject
end;

function SS_GetSymbolStatus( Handle: Pointer ): LongInt;
asm
  mov  ECX, Handle
  call DLL_SS_GetSymbolStatus
end;

function SS_GetTitle( Handle: Pointer; Title: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Title
  mov  ECX, Handle
  call DLL_SS_GetTitle
end;

function SS_Init( Handle: Pointer ): BOOL;
asm
  mov  ECX, Handle
  call DLL_SS_Init
end;

function SS_IsRequestPending( Handle: Pointer ): BOOL;
asm
  mov  ECX, Handle
  call DLL_SS_IsRequestPending
end;

procedure SS_LeaveRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_SS_LeaveRead
end;

function SS_RetDouble( Handle: Pointer; FieldIndex: LongInt ): Double;
asm
  push FieldIndex
  mov  ECX, Handle
  call DLL_SS_RetDouble
end;

function SS_RetDWord( Handle: Pointer; FieldIndex: LongInt ): DWORD;
asm
  push FieldIndex
  mov  ECX, Handle
  call DLL_SS_RetDWord
end;

procedure SS_SetSink( Handle: Pointer; Sink: ISSSetSink );
asm
  mov  ECX, Sink
  add  ECX, OFFSET Sink.FSinkMockup
  push ECX
  mov  ECX, Handle
  call DLL_SS_SetSink
end;


(* * * * * * * * * * * * * * * * * * *
 *       Level2Set Wrappers          *
 * * * * * * * * * * * * * * * * * * *)

procedure L2_EnterRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_L2_EnterRead
end;

function  L2_GetAskRecDWord( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; var Value: DWORD ): BOOL;
asm
  push Value
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_L2_GetAskRecDWord
end;

function  L2_GetAskRecString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Value
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_L2_GetAskRecString
end;

function  L2_GetBidRecDWord( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; var Value: DWORD ): BOOL;
asm
  push Value
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_L2_GetBidRecDWord
end;

function  L2_GetBidRecString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt; Value: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Value
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_L2_GetBidRecString
end;

function  L2_GetExpr( Handle: Pointer; Value: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;
asm
  push Permissions
  push Internal
  push BufferSize
  push Value
  mov  ECX, Handle
  call DLL_L2_GetExpr
end;

function  L2_GetNAsks( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_L2_GetNAsks
end;

function  L2_GetNBids( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_L2_GetNBids
end;

function  L2_GetNFields( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_L2_GetNFields
end;

function  L2_GetSink( Handle: Pointer ): ILevelIISetSink;
asm
  mov  ECX, Handle
  call DLL_L2_GetSink
  mov  EAX, TSinkMockup( [EAX] ).SinkObject
end;

function  L2_GetTitle( Handle: Pointer; Value: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Value
  mov  ECX, Handle
  call DLL_L2_GetTitle
end;

function  L2_Init( Handle: Pointer ): BOOL;
asm
  mov  ECX, Handle
  call DLL_L2_Init
end;

procedure L2_LeaveRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_L2_LeaveRead
end;

procedure L2_SetSink( Handle: Pointer; Sink: ILevelIISetSink );
asm
  mov  ECX, Sink
  add  ECX, OFFSET Sink.FSinkMockup
  push ECX
  mov  ECX, Handle
  call DLL_L2_SetSink
end;


(* * * * * * * * * * * * * * * * * * *
 *       SymbolSet Wrappers          *
 * * * * * * * * * * * * * * * * * * *)

procedure SY_EnterRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_SY_EnterRead
end;

function SY_GetExpr( Handle: Pointer; Expression: PChar; BufferSize: DWORD; Internal: BOOL; var Permissions: DWORD ): BOOL;
asm
  push Permissions
  push Internal
  push BufferSize
  push Expression
  mov  ECX, Handle
  call DLL_SY_GetExpr
end;

function SY_GetNFields( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_SY_GetNFields
end;

function SY_GetNSymbols( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_SY_GetNSymbols
end;

function SY_GetSink( Handle: Pointer ): ISymbolSetSink;
asm
  mov  ECX, Handle
  call DLL_SY_GetSink
  mov  EAX, TSinkMockup( [EAX] ).SinkObject
end;

function SY_GetString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt ): PChar;
asm
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_SY_GetString
end;

function SY_GetTitle( Handle: Pointer; Title: PChar; BufferSize: DWORD ): BOOL;
asm
  push BufferSize
  push Title
  mov  ECX, Handle
  call DLL_SY_GetTitle
end;

function SY_Init( Handle: Pointer ): BOOL;
asm
  mov  ECX, Handle
  call DLL_SY_Init
end;

procedure SY_LeaveRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_SY_LeaveRead
end;

procedure SY_SetSink( Handle: Pointer; Sink: ISymbolSetSink );
asm
  mov  ECX, Sink
  add  ECX, OFFSET Sink.FSinkMockup
  push ECX
  mov  ECX, Handle
  call DLL_SY_SetSink
end;



(* * * * * * * * * * * * * * * * * * *
 *       TopListSet Wrappers         *
 * * * * * * * * * * * * * * * * * * *)

procedure TL_EnterRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_TL_EnterRead
end;

function TL_GetNFields( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_TL_GetNFields
end;

function TL_GetNRecs( Handle: Pointer ): DWORD;
asm
  mov  ECX, Handle
  call DLL_TL_GetNRecs
end;

function TL_GetSink( Handle: Pointer ): ITLSetSink;
asm
  mov  ECX, Handle
  call DLL_TL_GetSink
  mov  EAX, TSinkMockup( [EAX] ).SinkObject
end;

function TL_GetString( Handle: Pointer; RecordIndex: LongInt; FieldIndex: LongInt ): PChar;
asm
  push FieldIndex
  push RecordIndex
  mov  ECX, Handle
  call DLL_TL_GetString
end;

procedure TL_GetTitle( Handle: Pointer; Title: PChar; BufferSize: DWORD );
asm
  push BufferSize
  push Title
  mov  ECX, Handle
  call DLL_TL_GetTitle
end;

function TL_Init( Handle: Pointer ): BOOL;
asm
  mov  ECX, Handle
  call DLL_TL_Init
end;

procedure TL_LeaveRead( Handle: Pointer );
asm
  mov  ECX, Handle
  call DLL_TL_LeaveRead
end;

procedure TL_SetSink( Handle: Pointer; Sink: ITLSetSink );
asm
  mov  ECX, Sink
  add  ECX, OFFSET Sink.FSinkMockup
  push ECX
  mov  ECX, Handle
  call DLL_TL_SetSink
end;








(* * * * * * * * * * * * * * * * * * *
 * Event Sink Object Implementations *
 * * * * * * * * * * * * * * * * * * *)


// Class TContinuumEventSink

constructor TContinuumEventSink.Create;
begin
  // Invoke ancestor constructor.
  inherited Create;

  // Set up internal sink record.
  Self.FSinkMockup.SinkObject := Self;
end;


// Class EConnectStatus

constructor EConnectStatus.Create;
  procedure DoLogon( UserName: PChar; Password: PChar ); stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    mov  EDX, UserName
    mov  ECX, Password
    call EConnectStatus( EAX ).DoLoggingOn
  end;
  procedure OnLogon( Status: LongInt ); stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    mov  EDX, Status
    call EConnectStatus( EAX ).DoLogonResult
  end;
  procedure OnLogoff; stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    call EConnectStatus( EAX ).DoLoggedOff
  end;
  procedure OnReady; stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    call EConnectStatus( EAX ).DoReady
  end;
  procedure OnStatusMessage( StatusMessage: PChar ); stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    mov  EDX, StatusMessage
    call EConnectStatus( EAX ).DoStatusMessage
  end;
begin
  // Invoke ancestor constructor.
  inherited Create;

  // Set up internal VTable record.
  Self.FSinkVTable.DoLogon         := @DoLogon;
  Self.FSinkVTable.OnLogon         := @OnLogon;
  Self.FSinkVTable.OnLogoff        := @OnLogoff;
  Self.FSinkVTable.OnReady         := @OnReady;
  Self.FSinkVTable.OnStatusMessage := @OnStatusMessage;

  // Set up internal sink record.
  Self.FSinkMockup.VTable     := @Self.FSinkVTable;
end;


procedure EConnectStatus.DoLoggingOn( UserName: PChar; Password: PChar );
begin
  // Invoke corresponding virtual function.
  Self.DoLogon( UserName, Password );
end;


procedure EConnectStatus.DoLogonResult( Status: LongInt );
begin
  // Invoke corresponding virtual function.
  Self.OnLogon( Status );
end;


procedure EConnectStatus.DoLoggedOff;
begin
  // Invoke corresponding virtual function.
  Self.OnLogoff;
end;


procedure EConnectStatus.DoReady;
begin
  // Invoke corresponding virtual function.
  Self.OnReady;
end;


procedure EConnectStatus.DoStatusMessage( StatusMessage: PChar );
begin
  // Invoke corresponding virtual function.
  Self.OnStatusMessage( StatusMessage );
end;


// Class TContinuumStandardEventSink

constructor TContinuumStandardEventSink.Create;
  procedure DataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD ); stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    mov  EDX, Handle
    mov  ECX, ChangeType
    push Param1
    push Param2
    call TContinuumStandardEventSink( EAX ).DoDataChange
  end;
begin
  // Invoke ancestor constructor.
  inherited Create;

  // Set up internal VTable record.
  Self.FSinkVTable.OnDataChange  := @DataChange;

  // Set up internal sink record.
  Self.FSinkMockup.VTable     := @Self.FSinkVTable;
end;


procedure TContinuumStandardEventSink.DoDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD );
begin
  // Invoke corresponding virtual function.
  Self.OnDataChange( Handle, ChangeType, Param1, Param2 );
end;


// Class ISSSetSink

constructor ISSSetSink.Create;
  procedure SnapshotDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD ); stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    mov  EDX, Handle
    mov  ECX, ChangeType
    push Param1
    push Param2
    call ISSSetSink( EAX ).DoDataChange
  end;
  procedure SnapshotFieldChange( Handle: Pointer; FieldCount: Byte; FieldIndices: PByte ); stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    mov  EDX, Handle
    mov  ECX, LongWord( FieldCount )
    push FieldIndices
    call ISSSetSink( EAX ).DoFieldChange
  end;
begin
  // Invoke ancestor constructor.
  inherited Create;

  // Set up internal VTable record.
  Self.FSinkVTable.OnDataChange  := @SnapshotDataChange;
  Self.FSinkVTable.OnFieldChange := @SnapshotFieldChange;

  // Set up internal sink record.
  Self.FSinkMockup.VTable     := @Self.FSinkVTable;
end;


procedure ISSSetSink.DoDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD );
begin
  // Invoke corresponding virtual function.
  Self.OnDataChange( Handle, ChangeType, Param1, Param2 );
end;


procedure ISSSetSink.DoFieldChange( Handle: Pointer; FieldCount: Byte; FieldIndices: PByte );
var
  Indices: Array of Byte;
begin
  // Transfer indices into a dynamic array.
  SetLength( Indices, FieldCount );
  Move( PChar( FieldIndices )[0], Indices[0], FieldCount );

  // Invoke corresponding virtual function.
  Self.OnFieldChange( Handle, FieldCount, Indices );
end;


// Class ILevelIISetSink

constructor ILevelIISetSink.Create;
  procedure Level2DataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD; Param3: DWORD ); stdcall;
  asm
    mov  EAX, TSinkMockup( [ECX] ).SinkObject
    mov  EDX, Handle
    mov  ECX, ChangeType
    push Param1
    push Param2
    push Param3
    call ILevelIISetSink( EAX ).DoDataChange
  end;
begin
  // Invoke ancestor constructor.
  inherited Create;

  // Set up internal VTable record.
  Self.FSinkVTable.OnDataChange  := @Level2DataChange;

  // Set up internal sink record.
  Self.FSinkMockup.VTable     := @Self.FSinkVTable;
end;


procedure ILevelIISetSink.DoDataChange( Handle: Pointer; ChangeType: DWORD; Param1: DWORD; Param2: DWORD; Param3: DWORD );
begin
  // Invoke corresponding virtual function.
  Self.OnDataChange( Handle, ChangeType, Param1, Param2, Param3 );
end;





initialization

  // Continuum is very multi-threaded. Ensure the System knows this.
  // Important for memory allocation thread-safety.
  System.IsMultiThread := True;

  // Get the real pointer to the singleton client object in the DLL.
  // This is just a formality; the pointer isn't really used for anything.
  DLL_ContinuumClient := PPointer( @pContinuumClient )^;

end.

