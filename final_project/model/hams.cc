#include <iostream>
using namespace std;

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
	friend ostream& operator <<(ostream& s, const DoubleLinkedList& list) {
    // s << "{";
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
  constexpr uint32_t size = 1000;
  LinkedList ll;
  uint32_t * unq_data = new uint32_t[size];
  for(uint32_t i=0;i<size; i++)
    unq_data[i]=i+1;
  fischeryates_shuffle(unq_data,0,size-1);
  for(uint32_t i=0;i<size; i++)
    ll.addEnd(unq_data[i]);
  
  cout << "rec: 0x" << ll[0] << ", key: " << rec[0].get_key() << ", rsvd: " << rec[0].get_rsvd() << endl;
  
  delete [] unq_data;
  
  return 0;
}