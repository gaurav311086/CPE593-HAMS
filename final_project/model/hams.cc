#include <iostream>
#include <algorithm>
#include <vector>
#include <fstream>
#include <iomanip>
using namespace std;

#undef DBLINKEDLIST

#ifdef DBLINKEDLIST
class LinkedList {
private:
	class Node {
	public:
		Node* next;
		uint32_t key;    
    Node(uint32_t v, Node* nxt) : key(v),nxt(nxt) {}
	};

	Node* head;
	Node* tail;
  int   size;
public:
	LinkedList() : head(nullptr),tail(nullptr),size(0) {}
  
  ~LinkedList() {
    Node *p = head;
    while(p){
      Node * delThisNode = p;
      p=p->next;
      delete delThisNode;
    }
    head=nullptr;
    tail=nullptr;
    size=0;
  }
	void addStart(int v) {
    head=new Node(v,head);
    if(!tail)
      tail = head;
    size++;
	}

	void addEnd(int v) {
    Node * tmp = tail;
    tail=new Node(v,nullptr);
    if(tmp)
      tmp->next = tail;
    if(!head)
      head = tail;
    size++;
	}
	// implement to print out the list
*    // s << "{";
    Node * p;
    if(!list.head)
      return s;
    for(p=list.head;p!=nullptr;p=p->next){
      if(p->next != nullptr)
        s << p->val << ",";
      else
        s << p->val;
    }
    // s << "}";
    return s;
	}
};
#endif

void exchange(uint32_t * a,uint32_t l, uint32_t r) {
  if(!a || (l==r))
    return;
  uint32_t tmp= a[l];
  a[l]=a[r];
  a[r]=tmp;
}
void  fischeryates_shuffle(uint32_t * a, uint32_t lo, uint32_t hi){
  uint32_t len = hi - lo + 1;
  for(uint32_t i =len-1; i >= lo+1; i--){
    uint32_t random_i = ((uint32_t) random())%(hi-lo+1);
    uint32_t r = lo + random_i;
    exchange(a,r,i);
  }
}

int main(){
  constexpr uint32_t size = 1024;
  // LinkedList ll;
  uint32_t * unq_data = new uint32_t[size];
  for(uint32_t i=0;i<size; i++)
    unq_data[i]=i+1;
  fischeryates_shuffle(unq_data,0,size-1);
  
  vector<int> myvector (unq_data, unq_data+size);

  for(int j=0;j<size;j=j+4){
    sort (myvector.begin()+(j), myvector.begin()+(j+4));
  }
  
  // open a file in write mode.
  ofstream outdata1;
  outdata1.open("output_data_ph1.txt");
  // write inputted data into the file.
  for (vector<int>::iterator it=myvector.begin(); it!=myvector.end(); ++it)
    outdata1 << hex << setw(8) << setfill('0') << *it << endl;
  
  
  // close the opened file.
  outdata1.close();
  

  // using default comparison (operator <):
  sort (myvector.begin(), myvector.end());
  
  // open a file in write mode.
  ofstream indata;
  indata.open("input_data.txt");
  // write inputted data into the file.
  for(uint32_t i=0;i<size; i++)
    indata << hex << unq_data[i] << endl;
  
  // close the opened file.
  indata.close();
  
  // open a file in write mode.
  ofstream outdata2;
  outdata2.open("output_data.txt");
  // write inputted data into the file.
  for (vector<int>::iterator it=myvector.begin(); it!=myvector.end(); ++it)
    outdata2 << hex << setw(8) << setfill('0') << *it << endl;
  
  // close the opened file.
  outdata2.close();
  
  delete [] unq_data;
  
  return 0;
}