#ifndef __SGCONTRACTSEARCH_H__
#define __SGCONTRACTSEARCH_H__

// Hash����ڵ�����
#define SG_HASH_ROOT_NUM                  64
// ���ƥ�䵽����ϵ������
#define SG_MAX_RESULT_NUMBER              32

// Hash��ڵ㣬�ĸ���Ա��ΪHASH�������Ǹ����⡣
typedef struct _sg_contact_node_t
{
	struct _sg_contact_node_t * next;
}sg_contact_node_t;

// ��ϵ����Ϣ�洢�ṹ��Ϊ�˼��ݲ�ͬ�ֻ�ƽ̨�����Բ�ʹ��MTK�Զ���ṹ
typedef struct
{

}sg_contact_info_t;


void SG_InitContactHash(void);
void SG_RefreshContactHash(void);
int  SG_SearchContactName(char * numbers, sg_contact_info_t result[]);

#endif

