<nav aria-label="<@liferay.language key="site-pages" />" class="${nav_css_class}" id="navigation" role="navigation">
	<ul role="menubar">
		<#list nav_items as nav_item>
			<#assign
				nav_item_attr_has_popup = ""
				nav_item_css_class = ""
				nav_item_layout = nav_item.getLayout()
			/>

			<#if nav_item.isSelected()>
				<#assign
					nav_item_attr_has_popup = "aria-haspopup='true'"
					nav_item_css_class = "selected"
				/>
			</#if>
			<#if stringUtil.equals(nav_item.getName(), "Main") || stringUtil.equals(nav_item.getName(), "External Links")>
				<li class="${nav_item_css_class}" id="layout_${nav_item.getLayoutId()}" role="presentation">
					<span><@liferay_theme["layout-icon"] layout=nav_item_layout /> ${nav_item.getName()}</span>

					<#if nav_item.hasChildren()>
						<ul class="child-menu" role="menu">
							<#list nav_item.getChildren() as nav_child>
								<#assign
								nav_child_css_class = ""
								/>

								<#if nav_item.isSelected()>
									<#assign
									nav_child_css_class = "selected"
									/>
								</#if>

								<li class="${nav_child_css_class}" id="layout_${nav_child.getLayoutId()}" role="presentation">
									<a href="${nav_child.getURL()}" ${nav_child.getTarget()} role="menuitem">${nav_child.getName()}</a>
								</li>
							</#list>
						</ul>
					</#if>
				</li>
			</#if>
		</#list>
	</ul>
</nav>
