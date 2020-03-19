//+------------------------------------------------------------------ß
//|                                                            JAson |
//|    This software is licensed under the MIT https://goo.gl/eyJgHe |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2017"
#property version "1.08"
#property strict
#define DEBUG_PRINT false
//------------------------------------------------------------------	enum enJAType
enum enJAType { jtUNDEF,jtNULL,jtBOOL,jtINT,jtDBL,jtSTR,jtARRAY,jtOBJ };
//------------------------------------------------------------------	class CJAVal
class CJAVal
  {
public:
   virtual void Clear() { m_parent=NULL; m_key=""; m_type=jtUNDEF; m_bv=false; m_iv=0; m_dv=0; m_sv=""; ArrayResize(m_e,0); }
   virtual bool Copy(const CJAVal &a) { m_key=a.m_key; CopyData(a); return true; }
   virtual void CopyData(const CJAVal &a) { m_type=a.m_type; m_bv=a.m_bv; m_iv=a.m_iv; m_dv=a.m_dv; m_sv=a.m_sv; CopyArr(a); }
   virtual void CopyArr(const CJAVal &a) { int n=ArrayResize(m_e,ArraySize(a.m_e)); for(int i=0; i<n; i++) { m_e[i]=a.m_e[i]; m_e[i].m_parent=GetPointer(this); } }

public:
   CJAVal            m_e[];
   string            m_key;
   string            m_lkey;
   CJAVal           *m_parent;
   enJAType          m_type;
   bool              m_bv;
   long              m_iv;
   double            m_dv;
   string            m_sv;
   static int        code_page;

public:
                     CJAVal() { Clear(); }
                     CJAVal(CJAVal *aparent,enJAType atype) { Clear(); m_type=atype; m_parent=aparent; }
                     CJAVal(enJAType t,string a) { Clear(); FromStr(t,a); }
                     CJAVal(const int a) { Clear(); m_type=jtINT; m_iv=a; m_dv=(double)m_iv; m_sv=IntegerToString(m_iv); m_bv=m_iv!=0; }
                     CJAVal(const long a) { Clear(); m_type=jtINT; m_iv=a; m_dv=(double)m_iv; m_sv=IntegerToString(m_iv); m_bv=m_iv!=0; }
                     CJAVal(const double a) { Clear(); m_type=jtDBL; m_dv=a; m_iv=(long)m_dv; m_sv=DoubleToString(m_dv); m_bv=m_iv!=0; }
                     CJAVal(const bool a) { Clear(); m_type=jtBOOL; m_bv=a; m_iv=m_bv; m_dv=m_bv; m_sv=IntegerToString(m_iv); }
                     CJAVal(const CJAVal &a) { Clear(); Copy(a); }
                    ~CJAVal() { Clear(); }

public:
   virtual bool IsNumeric() { return m_type==jtDBL || m_type==jtINT; }
   virtual CJAVal *FindKey(string akey) { for(int i=ArraySize(m_e)-1; i>=0; --i) if(m_e[i].m_key==akey) return GetPointer(m_e[i]); return NULL; }
   virtual CJAVal   *HasKey(string akey,enJAType atype=jtUNDEF);
   virtual CJAVal   *operator[](string akey);
   virtual CJAVal   *operator[](int i);
   void operator=(const CJAVal &a) { Copy(a); }
   void operator=(const int a) { m_type=jtINT; m_iv=a; m_dv=(double)m_iv; m_bv=m_iv!=0; }
   void operator=(const long a) { m_type=jtINT; m_iv=a; m_dv=(double)m_iv; m_bv=m_iv!=0; }
   void operator=(const double a) { m_type=jtDBL; m_dv=a; m_iv=(long)m_dv; m_bv=m_iv!=0; }
   void operator=(const bool a) { m_type=jtBOOL; m_bv=a; m_iv=(long)m_bv; m_dv=(double)m_bv; }
   void operator=(string a) { m_type=(a!=NULL)?jtSTR:jtNULL; m_sv=a; m_iv=StringToInteger(m_sv); m_dv=StringToDouble(m_sv); m_bv=a!=NULL; }

   bool operator==(const int a) { return m_iv==a; }
   bool operator==(const long a) { return m_iv==a; }
   bool operator==(const double a) { return m_dv==a; }
   bool operator==(const bool a) { return m_bv==a; }
   bool operator==(string a) { return m_sv==a; }

   bool operator!=(const int a) { return m_iv!=a; }
   bool operator!=(const long a) { return m_iv!=a; }
   bool operator!=(const double a) { return m_dv!=a; }
   bool operator!=(const bool a) { return m_bv!=a; }
   bool operator!=(string a) { return m_sv!=a; }

   long ToInt() const { return m_iv; }
   double ToDbl() const { return m_dv; }
   bool ToBool() const { return m_bv; }
   string ToStr() { return m_sv; }

   virtual void FromStr(enJAType t,string a)
     {
      m_type=t;
      switch(m_type)
        {
         case jtBOOL: m_bv=(StringToInteger(a)!=0); m_iv=(long)m_bv; m_dv=(double)m_bv; m_sv=a; break;
         case jtINT: m_iv=StringToInteger(a); m_dv=(double)m_iv; m_sv=a; m_bv=m_iv!=0; break;
         case jtDBL: m_dv=StringToDouble(a); m_iv=(long)m_dv; m_sv=a; m_bv=m_iv!=0; break;
         case jtSTR: m_sv=Unescape(a); m_type=(m_sv!=NULL)?jtSTR:jtNULL; m_iv=StringToInteger(m_sv); m_dv=StringToDouble(m_sv); m_bv=m_sv!=NULL; break;
        }
     }
   virtual string GetStr(char &js[],int i,int slen)
     {
#ifdef __MQL4__
      if(slen<=0) return "";
#endif
      char cc[];
      ArrayCopy(cc,js,0,i,slen);
      return CharArrayToString(cc, 0, WHOLE_ARRAY, CJAVal::code_page);
     }

   virtual void Set(const CJAVal &a) { if(m_type==jtUNDEF) m_type=jtOBJ; CopyData(a); }
   virtual void      Set(const CJAVal &list[]);
   virtual CJAVal *Add(const CJAVal &item) { if(m_type==jtUNDEF) m_type=jtARRAY; /*ASSERT(m_type==jtOBJ || m_type==jtARRAY);*/ return AddBase(item); } // добавление
   virtual CJAVal *Add(const int a) { CJAVal item(a); return Add(item); }
   virtual CJAVal *Add(const long a) { CJAVal item(a); return Add(item); }
   virtual CJAVal *Add(const double a) { CJAVal item(a); return Add(item); }
   virtual CJAVal *Add(const bool a) { CJAVal item(a); return Add(item); }
   virtual CJAVal *Add(string a) { CJAVal item(jtSTR,a); return Add(item); }
   virtual CJAVal *AddBase(const CJAVal &item) { int c=ArraySize(m_e); ArrayResize(m_e,c+1); m_e[c]=item; m_e[c].m_parent=GetPointer(this); return GetPointer(m_e[c]); } // добавление
   virtual CJAVal *New() { if(m_type==jtUNDEF) m_type=jtARRAY; /*ASSERT(m_type==jtOBJ || m_type==jtARRAY);*/ return NewBase(); } // добавление
   virtual CJAVal *NewBase() { int c=ArraySize(m_e); ArrayResize(m_e,c+1); return GetPointer(m_e[c]); } // добавление

   virtual string    Escape(string a);
   virtual string    Unescape(string a);
public:
   virtual void      Serialize(string &js,bool bf=false,bool bcoma=false);
   virtual string Serialize() { string js; Serialize(js); return js; }
   virtual bool      Deserialize(char &js[],int slen,int &i);
   virtual bool      ExtrStr(char &js[],int slen,int &i);
   virtual bool Deserialize(string js,int acp=CP_ACP) { int i=0; Clear(); CJAVal::code_page=acp; char arr[]; int slen=StringToCharArray(js,arr,0,WHOLE_ARRAY,CJAVal::code_page); return Deserialize(arr,slen,i); }
   virtual bool Deserialize(char &js[],int acp=CP_ACP) { int i=0; Clear(); CJAVal::code_page=acp; return Deserialize(js,ArraySize(js),i); }
  };

int CJAVal::code_page=CP_ACP;

//------------------------------------------------------------------	HasKey
CJAVal *CJAVal::HasKey(string akey,enJAType atype/*=jtUNDEF*/) { for(int i=0; i<ArraySize(m_e); i++) if(m_e[i].m_key==akey) { if(atype==jtUNDEF || atype==m_e[i].m_type) return GetPointer(m_e[i]); break; } return NULL; }
//------------------------------------------------------------------	operator[]
CJAVal *CJAVal::operator[](string akey) { if(m_type==jtUNDEF) m_type=jtOBJ; CJAVal *v=FindKey(akey); if(v) return v; CJAVal b(GetPointer(this),jtUNDEF); b.m_key=akey; v=Add(b); return v; }
//------------------------------------------------------------------	operator[]
CJAVal *CJAVal::operator[](int i)
  {
   if(m_type==jtUNDEF) m_type=jtARRAY;
   while(i>=ArraySize(m_e)) { CJAVal b(GetPointer(this),jtUNDEF); if(CheckPointer(Add(b))==POINTER_INVALID) return NULL; }
   return GetPointer(m_e[i]);
  }
//------------------------------------------------------------------	Set
void CJAVal::Set(const CJAVal &list[])
  {
   if(m_type==jtUNDEF) m_type=jtARRAY;
   int n=ArrayResize(m_e,ArraySize(list)); for(int i=0; i<n;++i) { m_e[i]=list[i]; m_e[i].m_parent=GetPointer(this); }
  }
//------------------------------------------------------------------	Serialize
void CJAVal::Serialize(string &js,bool bkey/*=false*/,bool coma/*=false*/)
  {
   if(m_type==jtUNDEF) return;
   if(coma) js+=",";
   if(bkey) js+=StringFormat("\"%s\":", m_key);
   int _n=ArraySize(m_e);
   switch(m_type)
     {
      case jtNULL: js+="null"; break;
      case jtBOOL: js+=(m_bv?"true":"false"); break;
      case jtINT: js+=IntegerToString(m_iv); break;
      case jtDBL: js+=DoubleToString(m_dv); break;
      case jtSTR: { string ss=Escape(m_sv); if(StringLen(ss)>0) js+=StringFormat("\"%s\"",ss); else js+="null"; } break;
      case jtARRAY: js+="["; for(int i=0; i<_n; i++) m_e[i].Serialize(js,false,i>0); js+="]"; break;
      case jtOBJ: js+="{"; for(int i=0; i<_n; i++) m_e[i].Serialize(js,true,i>0); js+="}"; break;
     }
  }
//------------------------------------------------------------------	Deserialize
bool CJAVal::Deserialize(char &js[],int slen,int &i)
  {
   string num="0123456789+-.eE";
   int i0=i;
   for(; i<slen; i++)
     {
      char c=js[i]; if(c==0) break;
      switch(c)
        {
         case '\t': case '\r': case '\n': case ' ': // пропускаем из имени пробелы
            i0=i+1; break;

         case '[': // начало массива. создаём объекты и забираем из js
           {
            i0=i+1;
            if(m_type!=jtUNDEF) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; } // если значение уже имеет тип, то это ошибка
            m_type=jtARRAY; // задали тип значения
            i++; CJAVal val(GetPointer(this),jtUNDEF);
            while(val.Deserialize(js,slen,i))
              {
               if(val.m_type!=jtUNDEF) Add(val);
               if(val.m_type==jtINT || val.m_type==jtDBL || val.m_type==jtARRAY) i++;
               val.Clear(); val.m_parent=GetPointer(this);
               if(js[i]==']') break;
               i++; if(i>=slen) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; }
              }
            return js[i]==']' || js[i]==0;
           }
         break;
         case ']': if(!m_parent) return false; return m_parent.m_type==jtARRAY; // конец массива, текущее значение должны быть массивом

         case ':':
           {
            if(m_lkey=="") { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; }
            CJAVal val(GetPointer(this),jtUNDEF);
            CJAVal *oc=Add(val); // тип объекта пока не определён
            oc.m_key=m_lkey; m_lkey=""; // задали имя ключа
            i++; if(!oc.Deserialize(js,slen,i)) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; }
            break;
           }
         case ',': // разделитель значений // тип значения уже должен быть определён
            i0=i+1;
            if(!m_parent && m_type!=jtOBJ) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; }
            else if(m_parent)
              {
               if(m_parent.m_type!=jtARRAY && m_parent.m_type!=jtOBJ) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; }
               if(m_parent.m_type==jtARRAY && m_type==jtUNDEF) return true;
              }
            break;

            // примитивы могут быть ТОЛЬКО в массиве / либо самостоятельно
         case '{': // начало объекта. создаем объект и забираем его из js
            i0=i+1;
            if(m_type!=jtUNDEF) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; }// ошибка типа
            m_type=jtOBJ; // задали тип значения
            i++; if(!Deserialize(js,slen,i)) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; } // вытягиваем его
            return js[i]=='}' || js[i]==0;
            break;
         case '}': return m_type==jtOBJ; // конец объекта, текущее значение должно быть объектом

         case 't': case 'T': // начало true
         case 'f': case 'F': // начало false
         if(m_type!=jtUNDEF) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; } // ошибка типа
         m_type=jtBOOL; // задали тип значения
         if(i+3<slen) { if(StringCompare(GetStr(js, i, 4), "true", false)==0) { m_bv=true; i+=3; return true; } }
         if(i+4<slen) { if(StringCompare(GetStr(js, i, 5), "false", false)==0) { m_bv=false; i+=4; return true; } }
         if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; // не тот тип или конец строки
         break;
         case 'n': case 'N': // начало null
         if(m_type!=jtUNDEF) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; } // ошибка типа
         m_type=jtNULL; // задали тип значения
         if(i+3<slen) if(StringCompare(GetStr(js,i,4),"null",false)==0) { i+=3; return true; }
         if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; // не NULL или конец строки
         break;

         case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '-': case '+': case '.': // начало числа
           {
            if(m_type!=jtUNDEF) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; } // ошибка типа
            bool dbl=false;// задали тип значения
            int is=i; while(js[i]!=0 && i<slen) { i++; if(StringFind(num,GetStr(js,i,1))<0) break; if(!dbl) dbl=(js[i]=='.' || js[i]=='e' || js[i]=='E'); }
            m_sv=GetStr(js,is,i-is);
            if(dbl) { m_type=jtDBL; m_dv=StringToDouble(m_sv); m_iv=(long)m_dv; m_bv=m_iv!=0; }
            else { m_type=jtINT; m_iv=StringToInteger(m_sv); m_dv=(double)m_iv; m_bv=m_iv!=0; } // уточнии тип значения
            i--; return true; // отодвинулись на 1 символ назад и вышли
            break;
           }
         case '\"': // начало или конец строки
            if(m_type==jtOBJ) // если тип еще неопределён и ключ не задан
              {
               i++; int is=i; if(!ExtrStr(js,slen,i)) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; } // это ключ, идём до конца строки
               m_lkey=GetStr(js,is,i-is);
              }
            else
              {
               if(m_type!=jtUNDEF) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; } // ошибка типа
               m_type=jtSTR; // задали тип значения
               i++; int is=i;
               if(!ExtrStr(js,slen,i)) { if(DEBUG_PRINT)Print(m_key+" "+string(__LINE__)); return false; }
               FromStr(jtSTR,GetStr(js,is,i-is));
               return true;
              }
            break;
        }
     }
   return true;
  }
//------------------------------------------------------------------	ExtrStr
bool CJAVal::ExtrStr(char &js[],int slen,int &i)
  {
   for(; js[i]!=0 && i<slen; i++)
     {
      char c=js[i];
      if(c=='\"') break; // конец строки
      if(c=='\\' && i+1<slen)
        {
         i++; c=js[i];
         switch(c)
           {
            case '/': case '\\': case '\"': case 'b': case 'f': case 'r': case 'n': case 't': break; // это разрешенные
            case 'u': // \uXXXX
              {
               i++;
               for(int j=0; j<4 && i<slen && js[i]!=0; j++,i++)
                 {
                  if(!((js[i]>='0' && js[i]<='9') || (js[i]>='A' && js[i]<='F') || (js[i]>='a' && js[i]<='f'))) { if(DEBUG_PRINT)Print(m_key+" "+CharToString(js[i])+" "+string(__LINE__)); return false; } // не hex
                 }
               i--;
               break;
              }
            default: break; /*{ return false; } // неразрешенный символ с экранированием */
           }
        }
     }
   return true;
  }
//------------------------------------------------------------------	Escape
string CJAVal::Escape(string a)
  {
   ushort as[], s[]; int n=StringToShortArray(a, as); if(ArrayResize(s, 2*n)!=2*n) return NULL;
   int j=0;
   for(int i=0; i<n; i++)
     {
      switch(as[i])
        {
         case '\\': s[j]='\\'; j++; s[j]='\\'; j++; break;
         case '"': s[j]='\\'; j++; s[j]='"'; j++; break;
         case '/': s[j]='\\'; j++; s[j]='/'; j++; break;
         case 8: s[j]='\\'; j++; s[j]='b'; j++; break;
         case 12: s[j]='\\'; j++; s[j]='f'; j++; break;
         case '\n': s[j]='\\'; j++; s[j]='n'; j++; break;
         case '\r': s[j]='\\'; j++; s[j]='r'; j++; break;
         case '\t': s[j]='\\'; j++; s[j]='t'; j++; break;
         default: s[j]=as[i]; j++; break;
        }
     }
   a=ShortArrayToString(s,0,j);
   return a;
  }
//------------------------------------------------------------------	Unescape
string CJAVal::Unescape(string a)
  {
   ushort as[], s[]; int n=StringToShortArray(a, as); if(ArrayResize(s, n)!=n) return NULL;
   int j=0,i=0;
   while(i<n)
     {
      ushort c=as[i];
      if(c=='\\' && i<n-1)
        {
         switch(as[i+1])
           {
            case '\\': c='\\'; i++; break;
            case '"': c='"'; i++; break;
            case '/': c='/'; i++; break;
            case 'b': c=8; /*08='\b'*/; i++; break;
            case 'f': c=12;/*0c=\f*/ i++; break;
            case 'n': c='\n'; i++; break;
            case 'r': c='\r'; i++; break;
            case 't': c='\t'; i++; break;
            /*
            case 'u': // \uXXXX
              {
               i+=2; ushort k=0;
               for(int jj=0; jj<4 && i<n; jj++,i++)
                 {
                  c=as[i]; ushort h=0;
                  if(c>='0' && c<='9') h=c-'0';
                  else if(c>='A' && c<='F') h=c-'A'+10;
                  else if(c>='a' && c<='f') h=c-'a'+10;
                  else break; // не hex
                  k+=h*(ushort)pow(16,(3-jj));
                 }
               i--;
               c=k;
               break;
              }
              */
           }
        }
      s[j]=c; j++; i++;
     }
   a=ShortArrayToString(s,0,j);
   return a;
  }
//+------------------------------------------------------------------+
