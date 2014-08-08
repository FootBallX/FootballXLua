#include "PomeloClient.h"
USING_NS_CC;


void connectCallback(pc_connect_t* req, int status)
{
	if (status == 0)
	{
		PomeloClient::getInstance()->pushMsg(PC_EVENT_CONNECTED, "");
	}
	else
	{
		PomeloClient::getInstance()->pushMsg(PC_EVENT_CONNECTEFAIL, "");
	}
}

void requestCallBack(pc_request_t *req, int status, json_t *resp) {
	const char* event = req->route;
	if(status == -1) {
		PomeloClient::getInstance()->pushMsg(std::string(event), std::string("{\"error\":true}"));
		PomeloClient::getInstance()->pushMsg(std::string(PC_EVENT_REQUESTFAIL), std::string(""));
	} else if(status == 0) {
		char* msg = json_dumps(resp, 0);
		PomeloClient::getInstance()->pushMsg(std::string(event), std::string(msg));
		free(msg);
	}
	json_t *msg = req->msg;
	json_decref(msg);
	pc_request_destroy(req);
}

void notifyCallBack(pc_notify_t *req, int status)
{
	const char* event = req->route;
	if(status == -1)
	{
		PomeloClient::getInstance()->pushMsg(std::string(event), std::string("{\"error\":true}"));
		PomeloClient::getInstance()->pushMsg(std::string(PC_EVENT_NOTIFYFAIL), std::string(""));
	}
	else
	{
		PomeloClient::getInstance()->pushMsg(std::string(event), std::string(""));
	}
	json_t *msg = req->msg;
	json_decref(msg);
	pc_notify_destroy(req);
}



void eventCallBack(pc_client_t *client, const char *event, void *data)
{
	char nullStr[] = "";
	void *msg = data ? data : (void*)nullStr;
	if(data)
	{
		msg = json_dumps((const json_t*)data, 0);
	}
	
	PomeloClient::getInstance()->pushMsg(std::string(event), std::string((const char*)msg));
	if(data)
	{
		free(msg);
	}
}

static PomeloClient *s_PomeloClient = NULL; // pointer to singleton
PomeloClient::PomeloClient(){
	Director::getInstance()->getScheduler()->schedule(schedule_selector(PomeloClient::dispatchCallbacks), this, 0, false);
	Director::getInstance()->getScheduler()->pauseTarget(this);

    task_count = 0;
}
PomeloClient::~PomeloClient(){
	Director::getInstance()->getScheduler()->unschedule(schedule_selector(PomeloClient::dispatchCallbacks), this);
}

void PomeloClient::dispatchRequest(){
    std::map<std::string, std::string> m;
	reponse_queue_mutex.lock();
    if (msgQueue.size()>0) {
        m = msgQueue.front();
        msgQueue.pop();
        decTaskCount();
    }
	reponse_queue_mutex.unlock();
    if (!m.empty()) {
        //CCLog("event: %s, msg: %s", m["event"].c_str(), m["msg"].c_str());
        callScriptHandler(m["event"].c_str(), m["msg"].c_str());
    }
}
void PomeloClient::dispatchCallbacks(float delta){
    dispatchRequest();
    
	task_count_mutex.lock();
    if (task_count==0) {
        Director::getInstance()->getScheduler()->pauseTarget(this);
    }

	task_count_mutex.unlock();
}

void PomeloClient::destroyInstance()
{
    if (s_PomeloClient) {
        
        s_PomeloClient->release();
    }
}

PomeloClient* PomeloClient::getInstance()
{
    if (s_PomeloClient == NULL) {
        s_PomeloClient = new PomeloClient();
    }
    return s_PomeloClient;
}

int PomeloClient::connect(const char* addr,int port){
    struct sockaddr_in address;
    memset(&address, 0, sizeof(struct sockaddr_in));
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = inet_addr(addr);
    
	client = pc_client_new_with_reconnect(2000, 10000, 0);
    
    int ret = pc_client_connect(client, &address);
    if(ret) {
        CCLOG("pc_client_connect error:%d", ret);
        pc_client_destroy(client);
    }
    return  ret;
}


int PomeloClient::connectA(const char* addr, int port)
{
	struct sockaddr_in address;
	memset(&address, 0, sizeof(struct sockaddr_in));
	address.sin_family = AF_INET;
	address.sin_port = htons(port);
	address.sin_addr.s_addr = inet_addr(addr);

	client = pc_client_new_with_reconnect(2000, 10000, 0);

	pc_connect_t* connect_t = pc_connect_req_new(&address);

	int ret = pc_client_connect2(client, connect_t, connectCallback);
	if (ret) {
		CCLOG("pc_client_connect2 error:%d", ret);
		pc_client_destroy(client);
	}
	return  ret;
}



void PomeloClient::disconnect() {
    if(client){
//              pc_client_stop(client);
        pc_client_destroy(client);
    }
}

void PomeloClient::request(const char *route, const char *str)
{
	pc_request_t *request = pc_request_new();
	json_error_t error;
	json_t *msg = json_loads(str, JSON_DECODE_ANY, &error);
	if(!msg)
	{
		pushMsg(std::string(route), std::string("{\"error\":true}"));
		pushMsg(std::string(PC_EVENT_REQUESTERR), std::string(""));
	}
	else
	{
		pc_request(client, request, route, msg, requestCallBack);
		//json_decref(msg);
	}
}


void PomeloClient::notify(const char *route, const char *str)
{
	pc_notify_t *notify = pc_notify_new();
	json_error_t error;
	json_t *msg = json_loads(str, JSON_DECODE_ANY, &error);
	if(!msg)
	{
		pushMsg(std::string(route), std::string("{\"error\":true}"));
		pushMsg(std::string(PC_EVENT_NOTIFYERR), std::string(""));
	}
	else
	{
		pc_notify(client, notify, route, msg, notifyCallBack);
		//json_decref(msg);
	}
}


int PomeloClient::addListener(const char* event){
    return pc_add_listener(client, event, eventCallBack);
}
void PomeloClient::removeListener(const char *event){
    pc_remove_listener(client, event, eventCallBack);
}

void PomeloClient::pushMsg(std::string event, std::string msg)
{
	std::map<std::string, std::string> m;
	m["event"] = event;
	m["msg"] = msg;
	reponse_queue_mutex.lock();
    msgQueue.push(m);
	reponse_queue_mutex.unlock();
    incTaskCount();
}

void PomeloClient::incTaskCount(){
	task_count_mutex.lock();
    task_count++;
	task_count_mutex.unlock();
    Director::getInstance()->getScheduler()->resumeTarget(s_PomeloClient);
}

void PomeloClient::decTaskCount(){
	task_count_mutex.lock();
    task_count--;
	task_count_mutex.unlock();
}
void PomeloClient::registerScriptHandler(LUA_FUNCTION funcID)
{
	this->scriptHandler = funcID;
}

void PomeloClient::unregisterScriptHandler(void)
{
	this->scriptHandler = 0;
}
void PomeloClient::callScriptHandler(const char* event, const char* msg) {
	// Calling lua handler function
	if (this->scriptHandler) {
		auto engine = LuaEngine::getInstance();
        
        auto pStack = engine->getLuaStack();
        lua_State *state = pStack->getLuaState();
        
		lua_pushstring(state, event);
        lua_pushstring(state, msg);
        pStack->executeFunctionByHandler(this->scriptHandler, 2);
		
	}
}