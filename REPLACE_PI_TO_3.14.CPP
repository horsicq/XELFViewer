#include <algorithm>
#include <iostream>
#include <vector>


using namespace std;

	 int replace(string s)
	 {
	 
		 if(s.length()==0)
		 return -1;
	 
	        if(s[0]=='p'&& s[1]=='i')
	 {
		        cout<<"3.14";
		        replace(s.substr(2));
		        return 0;
	 }
	 else
	 {
	     cout<<s[0];
	    replace(s.substr(1));
	    return 0;
	 }
	 }
int main() {
	
	replace("pippppppipiipppp");
	
	return 0;
}
