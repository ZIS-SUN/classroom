package com.seatreservation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.seatreservation.entity.Feedback;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface FeedbackMapper extends BaseMapper<Feedback> {
    
    /**
     * 分页查询反馈列表（管理员）
     */
    @Select({
        "<script>",
        "SELECT f.*, u.username, u.real_name, ",
        "admin.real_name as replied_by_name ",
        "FROM feedback f ",
        "LEFT JOIN sys_user u ON f.user_id = u.id ",
        "LEFT JOIN sys_user admin ON f.replied_by = admin.id ",
        "WHERE 1=1 ",
        "<if test='type != null and type != \"\"'>",
        "AND f.type = #{type} ",
        "</if>",
        "<if test='status != null and status != \"\"'>",
        "AND f.status = #{status} ",
        "</if>",
        "ORDER BY f.created_time DESC",
        "</script>"
    })
    IPage<Feedback> selectFeedbackPage(Page<?> page, 
                                      @Param("type") String type,
                                      @Param("status") String status);

    /**
     * 查询用户的反馈列表
     */
    @Select("SELECT * FROM feedback WHERE user_id = #{userId} ORDER BY created_time DESC")
    IPage<Feedback> selectByUserId(Page<?> page, @Param("userId") Long userId);
}