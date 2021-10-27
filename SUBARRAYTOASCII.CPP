#include <iostream>
using namespace std;


void
subseq (string s, string ans)
{
  if (s.length () == 0)
    {
      cout << ans << endl;
      return;
    }
  char ch = s[0];
  int code = ch;
  string ros = s.substr (1);
  // cout<<"\n the length of 1st string is....."<<s.length()<<endl;
  subseq (ros, ans);
  // cout<<"the value of ros"<<ros<<endl;
  subseq (ros, (ans + ch));
  // cout<<"\n the length of 2nd string is....."<<s.length()<<endl;
  subseq (ros, ans + to_string (code));

}

int main ()
{
  subseq ("ABC", "");
  return 0;
}
