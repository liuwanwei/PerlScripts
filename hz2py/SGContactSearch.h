#ifndef __SGCONTRACTSEARCH_H__
#define __SGCONTRACTSEARCH_H__

// Hash表根节点数量
#define SG_HASH_ROOT_NUM                  64
// 最大匹配到的联系人数量
#define SG_MAX_RESULT_NUMBER              32

// Hash表节点，哪个成员作为HASH对象，这是个问题。
typedef struct _sg_contact_node_t
{
	struct _sg_contact_node_t * next;
}sg_contact_node_t;

// 联系人信息存储结构，为了兼容不同手机平台，所以不使用MTK自定义结构
typedef struct
{

}sg_contact_info_t;


void SG_InitContactHash(void);
void SG_RefreshContactHash(void);
int  SG_SearchContactName(char * numbers, sg_contact_info_t result[]);

#endif

