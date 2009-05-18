#ifndef __INTERNAL_DEFINES_DREAMWIDTH_H__
#define __INTERNAL_DEFINES_DREAMWIDTH_H__

#define KVC_WILL(v) [self willChangeValueForKey:@#v];
#define KVC_DID(v) [self willChangeValueForKey:@#v];

#define REL_RET_COND(v,a) if (v != a) { [v release]; v = [a retain]; }
#define REL_CPY_COND(v,a) if (v != a) { [v release]; v = [a copy]; }

#define SETTER_RETAIN(v) KVC_WILL(v) REL_RET_COND(v,val) KVC_DID(v)
#define SETTER_ASSIGN(v) KVC_WILL(v) v = val; KVC_DID(v)
#define SETTER_COPY(v) KVC_WILL(v) REL_CPY_COND(v,val) KVC_DID(v)

#endif