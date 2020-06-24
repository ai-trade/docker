<style lang="scss" scoped>
/deep/ {

}
</style>

<template lang="pug">
form(@submit.prevent="submit" ref="form" :class="{VC:added}")
    .TC(v-if="added")
        .FC2
            .FC1
                .P {{form.name}} 保存成功
                .P
                    a.button(:href="'/build/'+added" @click="added=false") 返回编辑
                .P
                    a.blue.solid.button(href="/build" @click="reset") 浏览场地
    template(v-else)
        h1 TODO
//-
    .page(ref="page")
        | TEST
</template>

<script lang="coffee">

import Vue from 'vue'
import {Input,DatePicker,Radio} from 'element-ui'
[Input,DatePicker,Radio].forEach (e)-> Vue.use(e)

# export default {

FORM = {}
export default require("~coffee/_vue/form")(
    "*ur/build"
    FORM
    (form)->
        console.log form
        return
) {
data:->
    {
    }

components:{
    # qiniu_pic : require '~vue/_vue/qiniu/pic'
}

computed:{
    # test:()->
}

methods:{
    # test:()->
}
}

</script>
