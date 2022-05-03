<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/init.jsp" %>

<c:choose>
	<c:when test="<%= themeDisplay.isSignedIn() %>">

		<%
		String signedInAs = HtmlUtil.escape(user.getFullName());

		if (themeDisplay.isShowMyAccountIcon() && (themeDisplay.getURLMyAccount() != null)) {
			String myAccountURL = String.valueOf(themeDisplay.getURLMyAccount());

			signedInAs = "<a class=\"signed-in\" href=\"" + HtmlUtil.escape(myAccountURL) + "\">" + signedInAs + "</a>";
		}
		%>

		<liferay-ui:message arguments="<%= signedInAs %>" key="you-are-signed-in-as-x" translateArguments="<%= false %>" />
	</c:when>
	<c:otherwise>

		<%
		String formName = "loginForm";

		if (windowState.equals(LiferayWindowState.EXCLUSIVE)) {
			formName += "Modal";
		}

		String redirect = ParamUtil.getString(request, "redirect");

		String login = (String)SessionErrors.get(renderRequest, "login");

		if (Validator.isNull(login)) {
			login = LoginUtil.getLogin(request, "login", company);
		}

		String password = StringPool.BLANK;
		boolean rememberMe = ParamUtil.getBoolean(request, "rememberMe");

		if (Validator.isNull(authType)) {
			authType = company.getAuthType();
		}
		%>

		<portlet:actionURL name="/login/login" secure="<%= PropsValues.COMPANY_SECURITY_AUTH_REQUIRES_HTTPS || request.isSecure() %>" var="loginURL">
			<portlet:param name="mvcRenderCommandName" value="/login/login" />
		</portlet:actionURL>

		<portlet:renderURL var="createAccountURL">
			<portlet:param name="mvcRenderCommandName" value="/login/create_account" />
		</portlet:renderURL>

		<portlet:renderURL var="forgotPasswordURL">
			<portlet:param name="mvcRenderCommandName" value="/login/forgot_password" />
		</portlet:renderURL>

<aui:form action="<%= loginURL %>" autocomplete='<%= PropsValues.COMPANY_SECURITY_LOGIN_FORM_AUTOCOMPLETE ? "on" : "off" %>' cssClass="sign-in-form" method="post" name="<%= formName %>" onSubmit="event.preventDefault();" validateOnBlur="<%= false %>">
	<aui:input name="saveLastPath" type="hidden" value="<%= false %>" />
	<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
	<aui:input name="doActionAfterLogin" type="hidden" value="<%= portletName.equals(PortletKeys.FAST_LOGIN) ? true : false %>" />

	<div class="inline-alert-container lfr-alert-container"></div>

	<liferay-util:dynamic-include key="com.liferay.login.web#/login.jsp#alertPre" />

	<c:choose>
		<c:when test='<%= SessionMessages.contains(request, "forgotPasswordSent") %>'>
			<div class="alert alert-success">
				<liferay-ui:message key="your-request-completed-successfully" />
			</div>
		</c:when>
		<c:when test='<%= SessionMessages.contains(request, "userAdded") %>'>

			<%
				String userEmailAddress = (String)SessionMessages.get(request, "userAdded");
			%>

			<div class="alert alert-success">
				<liferay-ui:message key="thank-you-for-creating-an-account" />

				<c:if test="<%= company.isStrangersVerify() %>">
					<liferay-ui:message arguments="<%= HtmlUtil.escape(userEmailAddress) %>" key="your-email-verification-code-was-sent-to-x" translateArguments="<%= false %>" />
				</c:if>

				<c:if test="<%= PrefsPropsUtil.getBoolean(company.getCompanyId(), PropsKeys.ADMIN_EMAIL_USER_ADDED_ENABLED) %>">
					<c:choose>
						<c:when test="<%= PropsValues.LOGIN_CREATE_ACCOUNT_ALLOW_CUSTOM_PASSWORD %>">
							<liferay-ui:message key="use-your-password-to-login" />
						</c:when>
						<c:otherwise>
							<liferay-ui:message arguments="<%= HtmlUtil.escape(userEmailAddress) %>" key="you-can-set-your-password-following-instructions-sent-to-x" translateArguments="<%= false %>" />
						</c:otherwise>
					</c:choose>
				</c:if>
			</div>
		</c:when>
		<c:when test='<%= SessionMessages.contains(request, "userPending") %>'>

			<%
				String userEmailAddress = (String)SessionMessages.get(request, "userPending");
			%>

			<div class="alert alert-success">
				<liferay-ui:message arguments="<%= HtmlUtil.escape(userEmailAddress) %>" key="thank-you-for-creating-an-account.-you-will-be-notified-via-email-at-x-when-your-account-has-been-approved" translateArguments="<%= false %>" />
			</div>
		</c:when>
	</c:choose>

	<c:if test="<%= PropsValues.SESSION_ENABLE_PERSISTENT_COOKIES && PropsValues.SESSION_TEST_COOKIE_SUPPORT %>">
		<div class="alert alert-danger" id="<portlet:namespace />cookieDisabled" style="display: none;">
			<liferay-ui:message key="authentication-failed-please-enable-browser-cookies" />
		</div>
	</c:if>

	<liferay-ui:error exception="<%= AuthException.class %>" message="authentication-failed" />
	<liferay-ui:error exception="<%= CompanyMaxUsersException.class %>" message="unable-to-log-in-because-the-maximum-number-of-users-has-been-reached" />
	<liferay-ui:error exception="<%= CookieNotSupportedException.class %>" message="authentication-failed-please-enable-browser-cookies" />
	<liferay-ui:error exception="<%= NoSuchUserException.class %>" message="authentication-failed" />
	<liferay-ui:error exception="<%= PasswordExpiredException.class %>" message="your-password-has-expired" />
	<liferay-ui:error exception="<%= UserEmailAddressException.MustNotBeNull.class %>" message="please-enter-an-email-address" />
	<liferay-ui:error exception="<%= UserLockoutException.LDAPLockout.class %>" message="this-account-is-locked" />

	<liferay-ui:error exception="<%= UserLockoutException.PasswordPolicyLockout.class %>">

		<%
			UserLockoutException.PasswordPolicyLockout ule = (UserLockoutException.PasswordPolicyLockout)errorException;
		%>

		<c:choose>
			<c:when test="<%= ule.passwordPolicy.isRequireUnlock() %>">
				<liferay-ui:message key="this-account-is-locked" />
			</c:when>
			<c:otherwise>

				<%
					Format dateFormat = FastDateFormatFactoryUtil.getDateTime(FastDateFormatConstants.SHORT, FastDateFormatConstants.LONG, locale, TimeZone.getTimeZone(ule.user.getTimeZoneId()));
				%>

				<liferay-ui:message arguments="<%= dateFormat.format(ule.user.getUnlockDate()) %>" key="this-account-is-locked-until-x" translateArguments="<%= false %>" />
			</c:otherwise>
		</c:choose>
	</liferay-ui:error>

	<liferay-ui:error exception="<%= UserPasswordException.class %>" message="authentication-failed" />
	<liferay-ui:error exception="<%= UserScreenNameException.MustNotBeNull.class %>" message="the-screen-name-cannot-be-blank" />

	<liferay-util:dynamic-include key="com.liferay.login.web#/login.jsp#alertPost" />

	<aui:fieldset>

		<%
			String loginLabel = null;

			if (authType.equals(CompanyConstants.AUTH_TYPE_EA)) {
				loginLabel = "email-address";
			}
			else if (authType.equals(CompanyConstants.AUTH_TYPE_SN)) {
				loginLabel = "screen-name";
			}
			else if (authType.equals(CompanyConstants.AUTH_TYPE_ID)) {
				loginLabel = "id";
			}
		%>

		<style id="applicationStylesheet" type="text/css">
			.mediaViewInfo {
				--web-view-name: Sign In;
				--web-view-id: Sign_In;
				--web-scale-on-resize: true;
				--web-enable-deep-linking: true;
			}
			:root {
				--web-view-ids: Sign_In;
			}
			* {
				margin: 0;
				padding: 0;
				box-sizing: border-box;
				border: none;
			}
			#Sign_In {
				position: absolute;
				width: 1366px;
				height: 768px;
				background-color: rgba(251,251,251,1);
				overflow: hidden;
				--web-view-name: Sign In;
				--web-view-id: Sign_In;
				--web-scale-on-resize: true;
				--web-enable-deep-linking: true;
			}
			#Rectangle_6 {
				fill: rgba(8,125,193,1);
			}
			.Rectangle_6 {
				position: absolute;
				overflow: visible;
				width: 786px;
				height: 768px;
				left: 580px;
				top: 0px;
			}
			#METADATA_u {
				display: none;
				left: 0px;
				top: 0px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_i {
				display: none;
				left: 420.446px;
				top: 62.812px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_j {
				display: none;
				left: 740.395px;
				top: 190px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_k {
				display: none;
				left: 328px;
				top: 448px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_l {
				display: none;
				left: 572px;
				top: 462px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_m {
				display: none;
				left: 534px;
				top: 578px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_n {
				display: none;
				left: 548px;
				top: 592px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_o {
				display: none;
				left: 470px;
				top: 578px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_p {
				display: none;
				left: 484px;
				top: 592px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_q {
				display: none;
				left: 406px;
				top: 578px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_r {
				display: none;
				left: 420px;
				top: 592px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_s {
				display: none;
				left: 342px;
				top: 578px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_t {
				display: none;
				left: 356px;
				top: 592px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_u {
				display: none;
				left: 0px;
				top: 0px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_v {
				display: none;
				left: 328px;
				top: 392.005px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_w {
				display: none;
				left: 328px;
				top: 320px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_x {
				display: none;
				left: 574.043px;
				top: 335px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#Label {
				display: none;
				left: 328px;
				top: 294px;
				position: absolute;
				overflow: visible;
				width: 38px;
				white-space: nowrap;
				line-height: 19px;
				margin-top: -3px;
				text-align: left;
				font-family: Noto Sans;
				font-style: normal;
				font-weight: bold;
				font-size: 13px;
				color: rgba(61,61,61,1);
				letter-spacing: 0.4px;
			}
			#METADATA_z {
				display: none;
				left: 328px;
				top: 256px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_ {
				display: none;
				left: 574.043px;
				top: 271px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#Label_ {
				display: none;
				left: 328px;
				top: 230px;
				position: absolute;
				overflow: visible;
				width: 38px;
				white-space: nowrap;
				line-height: 19px;
				margin-top: -3px;
				text-align: left;
				font-family: Noto Sans;
				font-style: normal;
				font-weight: bold;
				font-size: 13px;
				color: rgba(61,61,61,1);
				letter-spacing: 0.4px;
			}
			#METADATA_ba {
				display: none;
				left: 1051px;
				top: 115px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#METADATA_bb {
				display: none;
				left: 1065px;
				top: 129px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#Line {
				fill: transparent;
				stroke: rgba(207,207,207,1);
				stroke-width: 2px;
				stroke-linejoin: miter;
				stroke-linecap: butt;
				stroke-miterlimit: 4;
				shape-rendering: auto;
			}
			.Line {
				overflow: visible;
				position: absolute;
				width: 71.796px;
				height: 2px;
				left: 141.795px;
				top: 527.318px;
				transform: matrix(1,0,0,1,0,0);
			}
			#Line_ {
				fill: transparent;
				stroke: rgba(207,207,207,1);
				stroke-width: 2px;
				stroke-linejoin: miter;
				stroke-linecap: butt;
				stroke-miterlimit: 4;
				shape-rendering: auto;
			}
			.Line_ {
				overflow: visible;
				position: absolute;
				width: 71.796px;
				height: 2px;
				left: 373.647px;
				top: 527.318px;
				transform: matrix(1,0,0,1,0,0);
			}
			#Typography_TAGUI_S {
				left: 231.993px;
				top: 517.318px;
				position: absolute;
				overflow: visible;
				width: 115px;
				white-space: nowrap;
				line-height: 18px;
				margin-top: -1.5px;
				text-align: center;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(35,31,32,1);
				letter-spacing: 0.4px;
			}
			#Area_DISPLAY_ELEMENTSLabelSTAT {
				fill: rgba(242,242,242,1);
				stroke: rgba(8,125,193,1);
				stroke-width: 2px;
				stroke-linejoin: miter;
				stroke-linecap: butt;
				stroke-miterlimit: 4;
				shape-rendering: auto;
			}
			.Area_DISPLAY_ELEMENTSLabelSTAT {
				position: absolute;
				overflow: visible;
				width: 31.493px;
				height: 31.493px;
				left: 142.821px;
				top: 382.35px;
			}
			#Check_DISPLAY_ELEMENTSLabelSTA {
				fill: transparent;
				stroke: rgba(8,125,193,1);
				stroke-width: 2px;
				stroke-linejoin: round;
				stroke-linecap: round;
				stroke-miterlimit: 4;
				shape-rendering: auto;
			}
			.Check_DISPLAY_ELEMENTSLabelSTA {
				overflow: visible;
				position: absolute;
				width: 11.574px;
				height: 6.341px;
				transform: matrix(1,0,0,1,152.8123,392.8766) rotate(-45deg);
				transform-origin: center;
				left: 0px;
				top: 0px;
			}
			#Label_ba {
				left: 190.485px;
				top: 389.16px;
				position: absolute;
				overflow: visible;
				width: 129px;
				white-space: nowrap;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(35,31,32,1);
			}
			#Area_DISPLAY_ELEMENTSDefaultST {
				fill: rgba(255,255,255,1);
				stroke: rgba(8,125,193,1);
				stroke-width: 2px;
				stroke-linejoin: miter;
				stroke-linecap: butt;
				stroke-miterlimit: 4;
				shape-rendering: auto;
			}
			.Area_DISPLAY_ELEMENTSDefaultST {
				position: absolute;
				overflow: visible;
				width: 302.623px;
				height: 47.665px;
				left: 142.821px;
				top: 289.853px;
			}
			#Value {
				left: 158.993px;
				top: 304.323px;
				position: absolute;
				overflow: visible;
				/*width: 67px;*/
				white-space: nowrap;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(62,62,62,1);
			}
			#Area_DISPLAY_ELEMENTSDefaultST_bc {
				fill: rgba(255,255,255,1);
				stroke: rgba(8,125,193,1);
				stroke-width: 2px;
				stroke-linejoin: miter;
				stroke-linecap: butt;
				stroke-miterlimit: 4;
				shape-rendering: auto;
			}
			.Area_DISPLAY_ELEMENTSDefaultST_bc {
				position: absolute;
				overflow: visible;
				width: 302.623px;
				height: 47.665px;
				left: 142.821px;
				top: 199.017px;
			}
			#Value_bd {
				left: 158.993px;
				top: 213.486px;
				position: absolute;
				overflow: visible;
				/*width: 131px;*/
				white-space: nowrap;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(62,62,62,1);
			}
			#Create_an_account_TAGA {
				left: 234.746px;
				top: 142.096px;
				position: absolute;
				overflow: visible;
				width: 128px;
				white-space: nowrap;
				line-height: 24px;
				margin-top: -4.5px;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(8,125,193,1);
				text-decoration: underline;
			}
			#New_user_TAGH6 {
				left: 142.821px;
				top: 142.096px;
				position: absolute;
				overflow: visible;
				width: 74px;
				white-space: nowrap;
				line-height: 24px;
				margin-top: -4.5px;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(35,31,32,1);
			}
			#Title_TAGH4 {
				left: 138.993px;
				top: 66.317px;
				position: absolute;
				overflow: visible;
				width: 151px;
				white-space: nowrap;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: normal;
				font-size: 48px;
				color: rgba(8,125,193,1);
			}
			#Button {
				position: absolute;
				width: 302.623px;
				height: 65.539px;
				left: 142.821px;
				top: 434px;
				overflow: visible;
			}
			#METADATA_bi {
				display: none;
				left: 0px;
				top: 0px;
				position: absolute;
				overflow: hidden;
				width: 9.512px;
				height: 8.511566162109375px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#Area {
				fill: transparent;
				stroke: rgba(8,125,193,1);
				stroke-width: 2px;
				stroke-linejoin: miter;
				stroke-linecap: round;
				stroke-miterlimit: 4;
				shape-rendering: auto;
			}
			.Area {
				position: absolute;
				overflow: visible;
				width: 302.623px;
				height: 65.539px;
				left: 0px;
				top: 0px;
			}
			#Label_bk {
				left: 127.812px;
				top: 24.27px;
				position: absolute;
				overflow: visible;
				width: 48px;
				white-space: nowrap;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(8,125,193,1);
			}
			#Button_bl {
				position: absolute;
				width: 303.648px;
				height: 65.539px;
				left: 141.795px;
				top: 556.656px;
				overflow: visible;
			}
			#METADATA_bm {
				display: none;
				left: 0px;
				top: 0px;
				position: absolute;
				overflow: hidden;
				width: 9.512px;
				height: 8.511566162109375px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#Area_bn {
				fill: rgba(8,125,193,1);
			}
			.Area_bn {
				position: absolute;
				overflow: visible;
				width: 303.648px;
				height: 65.539px;
				left: 0px;
				top: 0px;
			}
			#Label_bo {
				left: 13.619px;
				top: 22.684px;
				position: absolute;
				overflow: visible;
				width: 118px;
				white-space: nowrap;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(252,252,252,1);
			}
			#Icon {
				position: absolute;
				width: 17.023px;
				height: 17.023px;
				left: 273.007px;
				top: 23.832px;
				overflow: visible;
			}
			#METADATA_bq {
				display: none;
				left: 0px;
				top: 0px;
				position: absolute;
				overflow: hidden;
				width: 11px;
				height: 10px;
				text-align: left;
				font-family: Arial;
				font-style: normal;
				font-weight: normal;
				font-size: 3px;
			}
			#Area_br {
				opacity: 0;
				fill: rgba(255,255,255,1);
			}
			.Area_br {
				position: absolute;
				overflow: visible;
				width: 17.023px;
				height: 17.023px;
				left: 0px;
				top: 0px;
			}
			#Icon_bs {
				position: absolute;
				width: 13.095px;
				height: 17.023px;
				left: 1.964px;
				top: 0px;
				overflow: visible;
			}
			#bdca5121-645a-4f40-a71f-09e5c3 {
				fill: rgba(255,255,255,1);
			}
			.bdca5121-645a-4f40-a71f-09e5c3 {
				overflow: visible;
				position: absolute;
				width: 13.095px;
				height: 17.023px;
				left: 0px;
				top: 0px;
				transform: matrix(1,0,0,1,0,0);
			}
			#Group_4 {
				opacity: 0.07;
				position: absolute;
				width: 784.511px;
				height: 784.573px;
				left: 759.336px;
				top: 160.667px;
				overflow: visible;
			}
			#Group_3 {
				position: absolute;
				width: 784.511px;
				height: 784.573px;
				left: 0px;
				top: 0px;
				overflow: visible;
			}
			#Group_6 {
				position: absolute;
				width: 217.667px;
				height: 225.029px;
				left: 1120px;
				top: 525px;
				overflow: visible;
			}
			#Group_5 {
				position: absolute;
				width: 217.667px;
				height: 225.029px;
				left: 0px;
				top: 0px;
				overflow: visible;
			}
			#Welcome_To_Our_Employee_Portal {
				left: 731px;
				top: 337px;
				position: absolute;
				overflow: visible;
				width: 499px;
				white-space: nowrap;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 32px;
				color: rgba(252,252,252,1);
				text-transform: capitalize;
			}
			#Create_an_account_TAGA_bz {
				left: 142.821px;
				top: 251.265px;
				position: absolute;
				overflow: visible;
				width: 121px;
				white-space: nowrap;
				line-height: 24px;
				margin-top: -4.5px;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(8,125,193,1);
				text-decoration: underline;
			}
			#Create_an_account_TAGA_b {
				left: 142.821px;
				top: 344.265px;
				position: absolute;
				overflow: visible;
				width: 117px;
				white-space: nowrap;
				line-height: 24px;
				margin-top: -4.5px;
				text-align: left;
				font-family: NanumGothic;
				font-style: normal;
				font-weight: bold;
				font-size: 15px;
				color: rgba(8,125,193,1);
				text-decoration: underline;
			}
		</style>
		<script id="applicationScript">
			///////////////////////////////////////
			// INITIALIZATION
			///////////////////////////////////////

			/**
			 * Functionality for scaling, showing by media query, and navigation between multiple pages on a single page.
			 * Code subject to change.
			 **/

			if (window.console==null) { window["console"] = { log : function() {} } }; // some browsers do not set console

			var Application = function() {
				// event constants
				this.prefix = "--web-";
				this.NAVIGATION_CHANGE = "viewChange";
				this.VIEW_NOT_FOUND = "viewNotFound";
				this.VIEW_CHANGE = "viewChange";
				this.VIEW_CHANGING = "viewChanging";
				this.STATE_NOT_FOUND = "stateNotFound";
				this.APPLICATION_COMPLETE = "applicationComplete";
				this.APPLICATION_RESIZE = "applicationResize";
				this.SIZE_STATE_NAME = "data-is-view-scaled";
				this.STATE_NAME = this.prefix + "state";

				this.lastTrigger = null;
				this.lastView = null;
				this.lastState = null;
				this.lastOverlay = null;
				this.currentView = null;
				this.currentState = null;
				this.currentOverlay = null;
				this.currentQuery = {index: 0, rule: null, mediaText: null, id: null};
				this.inclusionQuery = "(min-width: 0px)";
				this.exclusionQuery = "none and (min-width: 99999px)";
				this.LastModifiedDateLabelName = "LastModifiedDateLabel";
				this.viewScaleSliderId = "ViewScaleSliderInput";
				this.pageRefreshedName = "showPageRefreshedNotification";
				this.application = null;
				this.applicationStylesheet = null;
				this.showByMediaQuery = null;
				this.mediaQueryDictionary = {};
				this.viewsDictionary = {};
				this.addedViews = [];
				this.viewStates = [];
				this.views = [];
				this.viewIds = [];
				this.viewQueries = {};
				this.overlays = {};
				this.overlayIds = [];
				this.numberOfViews = 0;
				this.verticalPadding = 0;
				this.horizontalPadding = 0;
				this.stateName = null;
				this.viewScale = 1;
				this.viewLeft = 0;
				this.viewTop = 0;
				this.horizontalScrollbarsNeeded = false;
				this.verticalScrollbarsNeeded = false;

				// view settings
				this.showUpdateNotification = false;
				this.showNavigationControls = false;
				this.scaleViewsToFit = false;
				this.scaleToFitOnDoubleClick = false;
				this.actualSizeOnDoubleClick = false;
				this.scaleViewsOnResize = false;
				this.navigationOnKeypress = false;
				this.showViewName = false;
				this.enableDeepLinking = true;
				this.refreshPageForChanges = false;
				this.showRefreshNotifications = true;

				// view controls
				this.scaleViewSlider = null;
				this.lastModifiedLabel = null;
				this.supportsPopState = false; // window.history.pushState!=null;
				this.initialized = false;

				// refresh properties
				this.refreshDuration = 250;
				this.lastModifiedDate = null;
				this.refreshRequest = null;
				this.refreshInterval = null;
				this.refreshContent = null;
				this.refreshContentSize = null;
				this.refreshCheckContent = false;
				this.refreshCheckContentSize = false;

				var self = this;

				self.initialize = function(event) {
					var view = self.getVisibleView();
					var views = self.getVisibleViews();
					if (view==null) view = self.getInitialView();
					self.collectViews();
					self.collectOverlays();
					self.collectMediaQueries();

					for (let index = 0; index < views.length; index++) {
						var view = views[index];
						self.setViewOptions(view);
						self.setViewVariables(view);
						self.centerView(view);
					}

					// sometimes the body size is 0 so we call this now and again later
					if (self.initialized) {
						window.addEventListener(self.NAVIGATION_CHANGE, self.viewChangeHandler);
						window.addEventListener("keyup", self.keypressHandler);
						window.addEventListener("keypress", self.keypressHandler);
						window.addEventListener("resize", self.resizeHandler);
						window.document.addEventListener("dblclick", self.doubleClickHandler);

						if (self.supportsPopState) {
							window.addEventListener('popstate', self.popStateHandler);
						}
						else {
							window.addEventListener('hashchange', self.hashChangeHandler);
						}

						// we are ready to go
						window.dispatchEvent(new Event(self.APPLICATION_COMPLETE));
					}

					if (self.initialized==false) {
						if (self.enableDeepLinking) {
							self.syncronizeViewToURL();
						}

						if (self.refreshPageForChanges) {
							self.setupRefreshForChanges();
						}

						self.initialized = true;
					}

					if (self.scaleViewsToFit) {
						self.viewScale = self.scaleViewToFit(view);

						if (self.viewScale<0) {
							setTimeout(self.scaleViewToFit, 500, view);
						}
					}
					else if (view) {
						self.viewScale = self.getViewScaleValue(view);
						self.centerView(view);
						self.updateSliderValue(self.viewScale);
					}
					else {
						// no view found
					}

					if (self.showUpdateNotification) {
						self.showNotification();
					}

					//"addEventListener" in window ? null : window.addEventListener = window.attachEvent;
					//"addEventListener" in document ? null : document.addEventListener = document.attachEvent;
				}


				///////////////////////////////////////
				// AUTO REFRESH
				///////////////////////////////////////

				self.setupRefreshForChanges = function() {
					self.refreshRequest = new XMLHttpRequest();

					if (!self.refreshRequest) {
						return false;
					}

					// get document start values immediately
					self.requestRefreshUpdate();
				}

				/**
				 * Attempt to check the last modified date by the headers
				 * or the last modified property from the byte array (experimental)
				 **/
				self.requestRefreshUpdate = function() {
					var url = document.location.href;
					var protocol = window.location.protocol;
					var method;

					try {

						if (self.refreshCheckContentSize) {
							self.refreshRequest.open('HEAD', url, true);
						}
						else if (self.refreshCheckContent) {
							self.refreshContent = document.documentElement.outerHTML;
							self.refreshRequest.open('GET', url, true);
							self.refreshRequest.responseType = "text";
						}
						else {

							// get page last modified date for the first call to compare to later
							if (self.lastModifiedDate==null) {

								// File system does not send headers in FF so get blob if possible
								if (protocol=="file:") {
									self.refreshRequest.open("GET", url, true);
									self.refreshRequest.responseType = "blob";
								}
								else {
									self.refreshRequest.open("HEAD", url, true);
									self.refreshRequest.responseType = "blob";
								}

								self.refreshRequest.onload = self.refreshOnLoadOnceHandler;

								// In some browsers (Chrome & Safari) this error occurs at send:
								//
								// Chrome - Access to XMLHttpRequest at 'file:///index.html' from origin 'null'
								// has been blocked by CORS policy:
								// Cross origin requests are only supported for protocol schemes:
								// http, data, chrome, chrome-extension, https.
								//
								// Safari - XMLHttpRequest cannot load file:///Users/user/Public/index.html. Cross origin requests are only supported for HTTP.
								//
								// Solution is to run a local server, set local permissions or test in another browser
								self.refreshRequest.send(null);

								// In MS browsers the following behavior occurs possibly due to an AJAX call to check last modified date:
								//
								// DOM7011: The code on this page disabled back and forward caching.

								// In Brave (Chrome) error when on the server
								// index.js:221 HEAD https://www.example.com/ net::ERR_INSUFFICIENT_RESOURCES
								// self.refreshRequest.send(null);

							}
							else {
								self.refreshRequest = new XMLHttpRequest();
								self.refreshRequest.onreadystatechange = self.refreshHandler;
								self.refreshRequest.ontimeout = function() {
									self.log("Couldn't find page to check for updates");
								}

								var method;
								if (protocol=="file:") {
									method = "GET";
								}
								else {
									method = "HEAD";
								}

								//refreshRequest.open('HEAD', url, true);
								self.refreshRequest.open(method, url, true);
								self.refreshRequest.responseType = "blob";
								self.refreshRequest.send(null);
							}
						}
					}
					catch (error) {
						self.log("Refresh failed for the following reason:")
						self.log(error);
					}
				}

				self.refreshHandler = function() {
					var contentSize;

					try {

						if (self.refreshRequest.readyState === XMLHttpRequest.DONE) {

							if (self.refreshRequest.status === 2 ||
									self.refreshRequest.status === 200) {
								var pageChanged = false;

								self.updateLastModifiedLabel();

								if (self.refreshCheckContentSize) {
									var lastModifiedHeader = self.refreshRequest.getResponseHeader("Last-Modified");
									contentSize = self.refreshRequest.getResponseHeader("Content-Length");
									//lastModifiedDate = refreshRequest.getResponseHeader("Last-Modified");
									var headers = self.refreshRequest.getAllResponseHeaders();
									var hasContentHeader = headers.indexOf("Content-Length")!=-1;

									if (hasContentHeader) {
										contentSize = self.refreshRequest.getResponseHeader("Content-Length");

										// size has not been set yet
										if (self.refreshContentSize==null) {
											self.refreshContentSize = contentSize;
											// exit and let interval call this method again
											return;
										}

										if (contentSize!=self.refreshContentSize) {
											pageChanged = true;
										}
									}
								}
								else if (self.refreshCheckContent) {

									if (self.refreshRequest.responseText!=self.refreshContent) {
										pageChanged = true;
									}
								}
								else {
									lastModifiedHeader = self.getLastModified(self.refreshRequest);

									if (self.lastModifiedDate!=lastModifiedHeader) {
										self.log("lastModifiedDate:" + self.lastModifiedDate + ",lastModifiedHeader:" +lastModifiedHeader);
										pageChanged = true;
									}

								}


								if (pageChanged) {
									clearInterval(self.refreshInterval);
									self.refreshUpdatedPage();
									return;
								}

							}
							else {
								self.log('There was a problem with the request.');
							}

						}
					}
					catch( error ) {
						//console.log('Caught Exception: ' + error);
					}
				}

				self.refreshOnLoadOnceHandler = function(event) {

					// get the last modified date
					if (self.refreshRequest.response) {
						self.lastModifiedDate = self.getLastModified(self.refreshRequest);

						if (self.lastModifiedDate!=null) {

							if (self.refreshInterval==null) {
								self.refreshInterval = setInterval(self.requestRefreshUpdate, self.refreshDuration);
							}
						}
						else {
							self.log("Could not get last modified date from the server");
						}
					}
				}

				self.refreshUpdatedPage = function() {
					if (self.showRefreshNotifications) {
						var date = new Date().setTime((new Date().getTime()+10000));
						document.cookie = encodeURIComponent(self.pageRefreshedName) + "=true" + "; max-age=6000;" + " path=/";
					}

					document.location.reload(true);
				}

				self.showNotification = function(duration) {
					var notificationID = self.pageRefreshedName+"ID";
					var notification = document.getElementById(notificationID);
					if (duration==null) duration = 4000;

					if (notification!=null) {return;}

					notification = document.createElement("div");
					notification.id = notificationID;
					notification.textContent = "PAGE UPDATED";
					var styleRule = ""
					styleRule = "position: fixed; padding: 7px 16px 6px 16px; font-family: Arial, sans-serif; font-size: 10px; font-weight: bold; left: 50%;";
					styleRule += "top: 20px; background-color: rgba(0,0,0,.5); border-radius: 12px; color:rgb(235, 235, 235); transition: all 2s linear;";
					styleRule += "transform: translateX(-50%); letter-spacing: .5px; filter: drop-shadow(2px 2px 6px rgba(0, 0, 0, .1)); cursor: pointer";
					notification.setAttribute("style", styleRule);

					notification.className = "PageRefreshedClass";
					notification.addEventListener("click", function() {
						notification.parentNode.removeChild(notification);
					});

					document.body.appendChild(notification);

					setTimeout(function() {
						notification.style.opacity = "0";
						notification.style.filter = "drop-shadow( 0px 0px 0px rgba(0,0,0, .5))";
						setTimeout(function() {
							try {
								notification.parentNode.removeChild(notification);
							} catch(error) {}
						}, duration)
					}, duration);

					document.cookie = encodeURIComponent(self.pageRefreshedName) + "=; max-age=1; path=/";
				}

				/**
				 * Get the last modified date from the header
				 * or file object after request has been received
				 **/
				self.getLastModified = function(request) {
					var date;

					// file protocol - FILE object with last modified property
					if (request.response && request.response.lastModified) {
						date = request.response.lastModified;
					}

					// http protocol - check headers
					if (date==null) {
						date = request.getResponseHeader("Last-Modified");
					}

					return date;
				}

				self.updateLastModifiedLabel = function() {
					var labelValue = "";

					if (self.lastModifiedLabel==null) {
						self.lastModifiedLabel = document.getElementById("LastModifiedLabel");
					}

					if (self.lastModifiedLabel) {
						var seconds = parseInt(((new Date().getTime() - Date.parse(document.lastModified)) / 1000 / 60) * 100 + "");
						var minutes = 0;
						var hours = 0;

						if (seconds < 60) {
							seconds = Math.floor(seconds/10)*10;
							labelValue = seconds + " seconds";
						}
						else {
							minutes = parseInt((seconds/60) + "");

							if (minutes>60) {
								hours = parseInt((seconds/60/60) +"");
								labelValue += hours==1 ? " hour" : " hours";
							}
							else {
								labelValue = minutes+"";
								labelValue += minutes==1 ? " minute" : " minutes";
							}
						}

						if (seconds<10) {
							labelValue = "Updated now";
						}
						else {
							labelValue = "Updated " + labelValue + " ago";
						}

						if (self.lastModifiedLabel.firstElementChild) {
							self.lastModifiedLabel.firstElementChild.textContent = labelValue;

						}
						else if ("textContent" in self.lastModifiedLabel) {
							self.lastModifiedLabel.textContent = labelValue;
						}
					}
				}

				self.getShortString = function(string, length) {
					if (length==null) length = 30;
					string = string!=null ? string.substr(0, length).replace(/\n/g, "") : "[String is null]";
					return string;
				}

				self.getShortNumber = function(value, places) {
					if (places==null || places<1) places = 4;
					value = Math.round(value * Math.pow(10,places)) / Math.pow(10, places);
					return value;
				}

				///////////////////////////////////////
				// NAVIGATION CONTROLS
				///////////////////////////////////////

				self.updateViewLabel = function() {
					var viewNavigationLabel = document.getElementById("ViewNavigationLabel");
					var view = self.getVisibleView();
					var viewIndex = view ? self.getViewIndex(view) : -1;
					var viewName = view ? self.getViewPreferenceValue(view, self.prefix + "view-name") : null;
					var viewId = view ? view.id : null;

					if (viewNavigationLabel && view) {
						if (viewName && viewName.indexOf('"')!=-1) {
							viewName = viewName.replace(/"/g, "");
						}

						if (self.showViewName) {
							viewNavigationLabel.textContent = viewName;
							self.setTooltip(viewNavigationLabel, viewIndex + 1 + " of " + self.numberOfViews);
						}
						else {
							viewNavigationLabel.textContent = viewIndex + 1 + " of " + self.numberOfViews;
							self.setTooltip(viewNavigationLabel, viewName);
						}

					}
				}

				self.updateURL = function(view) {
					view = view == null ? self.getVisibleView() : view;
					var viewId = view ? view.id : null
					var viewFragment = view ? "#"+ viewId : null;

					if (viewId && self.viewIds.length>1 && self.enableDeepLinking) {

						if (self.supportsPopState==false) {
							self.setFragment(viewId);
						}
						else {
							if (viewFragment!=window.location.hash) {

								if (window.location.hash==null) {
									window.history.replaceState({name:viewId}, null, viewFragment);
								}
								else {
									window.history.pushState({name:viewId}, null, viewFragment);
								}
							}
						}
					}
				}

				self.updateURLState = function(view, stateName) {
					stateName = view && (stateName=="" || stateName==null) ? self.getStateNameByViewId(view.id) : stateName;

					if (self.supportsPopState==false) {
						self.setFragment(stateName);
					}
					else {
						if (stateName!=window.location.hash) {

							if (window.location.hash==null) {
								window.history.replaceState({name:view.viewId}, null, stateName);
							}
							else {
								window.history.pushState({name:view.viewId}, null, stateName);
							}
						}
					}
				}

				self.setFragment = function(value) {
					window.location.hash = "#" + value;
				}

				self.setTooltip = function(element, value) {
					// setting the tooltip in edge causes a page crash on hover
					if (/Edge/.test(navigator.userAgent)) { return; }

					if ("title" in element) {
						element.title = value;
					}
				}

				self.getStylesheetRules = function(styleSheet) {
					try {
						if (styleSheet) return styleSheet.cssRules || styleSheet.rules;

						return document.styleSheets[0]["cssRules"] || document.styleSheets[0]["rules"];
					}
					catch (error) {
						// ERRORS:
						// SecurityError: The operation is insecure.
						// Errors happen when script loads before stylesheet or loading an external css locally

						// InvalidAccessError: A parameter or an operation is not supported by the underlying object
						// Place script after stylesheet

						console.log(error);
						if (error.toString().indexOf("The operation is insecure")!=-1) {
							console.log("Load the stylesheet before the script or load the stylesheet inline until it can be loaded on a server")
						}
						return [];
					}
				}

				/**
				 * If single page application hide all of the views.
				 * @param {Number} selectedIndex if provided shows the view at index provided
				 **/
				self.hideViews = function(selectedIndex, animation) {
					var rules = self.getStylesheetRules();
					var queryIndex = 0;
					var numberOfRules = rules!=null ? rules.length : 0;

					// loop through rules and hide media queries except selected
					for (var i=0;i<numberOfRules;i++) {
						var rule = rules[i];
						var cssText = rule && rule.cssText;

						if (rule.media!=null && cssText.match("--web-view-name:")) {

							if (queryIndex==selectedIndex) {
								self.currentQuery.mediaText = rule.conditionText;
								self.currentQuery.index = selectedIndex;
								self.currentQuery.rule = rule;
								self.enableMediaQuery(rule);
							}
							else {
								if (animation) {
									self.fadeOut(rule)
								}
								else {
									self.disableMediaQuery(rule);
								}
							}

							queryIndex++;
						}
					}

					self.numberOfViews = queryIndex;
					self.updateViewLabel();
					self.updateURL();

					self.dispatchViewChange();

					var view = self.getVisibleView();
					var viewIndex = view ? self.getViewIndex(view) : -1;

					return viewIndex==selectedIndex ? view : null;
				}

				/**
				 * If single page application hide all of the views.
				 * @param {HTMLElement} selectedView if provided shows the view passed in
				 **/
				self.hideAllViews = function(selectedView, animation) {
					var views = self.views;
					var queryIndex = 0;
					var numberOfViews = views!=null ? views.length : 0;

					// loop through rules and hide media queries except selected
					for (var i=0;i<numberOfViews;i++) {
						var viewData = views[i];
						var view = viewData && viewData.view;
						var mediaRule = viewData && viewData.mediaRule;

						if (view==selectedView) {
							self.currentQuery.mediaText = mediaRule.conditionText;
							self.currentQuery.index = queryIndex;
							self.currentQuery.rule = mediaRule;
							self.enableMediaQuery(mediaRule);
						}
						else {
							if (animation) {
								self.fadeOut(mediaRule)
							}
							else {
								self.disableMediaQuery(mediaRule);
							}
						}

						queryIndex++;
					}

					self.numberOfViews = queryIndex;
					self.updateViewLabel();
					self.updateURL();
					self.dispatchViewChange();

					var visibleView = self.getVisibleView();

					return visibleView==selectedView ? selectedView : null;
				}

				/**
				 * Hide view
				 * @param {Object} view element to hide
				 **/
				self.hideView = function(view) {
					var rule = view ? self.mediaQueryDictionary[view.id] : null;

					if (rule) {
						self.disableMediaQuery(rule);
					}
				}

				/**
				 * Hide overlay
				 * @param {Object} overlay element to hide
				 **/
				self.hideOverlay = function(overlay) {
					var rule = overlay ? self.mediaQueryDictionary[overlay.id] : null;

					if (rule) {
						self.disableMediaQuery(rule);

						//if (self.showByMediaQuery) {
						overlay.style.display = "none";
						//}
					}
				}

				/**
				 * Show the view by media query. Does not hide current views
				 * Sets view options by default
				 * @param {Object} view element to show
				 * @param {Boolean} setViewOptions sets view options if null or true
				 */
				self.showViewByMediaQuery = function(view, setViewOptions) {
					var id = view ? view.id : null;
					var query = id ? self.mediaQueryDictionary[id] : null;
					var isOverlay = view ? self.isOverlay(view) : false;
					setViewOptions = setViewOptions==null ? true : setViewOptions;

					if (query) {
						self.enableMediaQuery(query);

						if (isOverlay && view && setViewOptions) {
							self.setViewVariables(null, view);
						}
						else {
							if (view && setViewOptions) self.setViewOptions(view);
							if (view && setViewOptions) self.setViewVariables(view);
						}
					}
				}

				/**
				 * Show the view. Does not hide current views
				 */
				self.showView = function(view, setViewOptions) {
					var id = view ? view.id : null;
					var query = id ? self.mediaQueryDictionary[id] : null;
					var display = null;
					setViewOptions = setViewOptions==null ? true : setViewOptions;

					if (query) {
						self.enableMediaQuery(query);
						if (view==null) view =self.getVisibleView();
						if (view && setViewOptions) self.setViewOptions(view);
					}
					else if (id) {
						display = window.getComputedStyle(view).getPropertyValue("display");
						if (display=="" || display=="none") {
							view.style.display = "block";
						}
					}

					if (view) {
						if (self.currentView!=null) {
							self.lastView = self.currentView;
						}

						self.currentView = view;
					}
				}

				self.showViewById = function(id, setViewOptions) {
					var view = id ? self.getViewById(id) : null;

					if (view) {
						self.showView(view);
						return;
					}

					self.log("View not found '" + id + "'");
				}

				self.getElementView = function(element) {
					var view = element;
					var viewFound = false;

					while (viewFound==false || view==null) {
						if (view && self.viewsDictionary[view.id]) {
							return view;
						}
						view = view.parentNode;
					}
				}

				/**
				 * Show overlay over view
				 * @param {Event | HTMLElement} event event or html element with styles applied
				 * @param {String} id id of view or view reference
				 * @param {Number} x x location
				 * @param {Number} y y location
				 */
				self.showOverlay = function(event, id, x, y) {
					var overlay = id && typeof id === 'string' ? self.getViewById(id) : id ? id : null;
					var query = overlay ? self.mediaQueryDictionary[overlay.id] : null;
					var centerHorizontally = false;
					var centerVertically = false;
					var anchorLeft = false;
					var anchorTop = false;
					var anchorRight = false;
					var anchorBottom = false;
					var display = null;
					var reparent = true;
					var view = null;

					if (overlay==null || overlay==false) {
						self.log("Overlay not found, '"+ id + "'");
						return;
					}

					// get enter animation - event target must have css variables declared
					if (event) {
						var button = event.currentTarget || event; // can be event or htmlelement
						var buttonComputedStyles = getComputedStyle(button);
						var actionTargetValue = buttonComputedStyles.getPropertyValue(self.prefix+"action-target").trim();
						var animation = buttonComputedStyles.getPropertyValue(self.prefix+"animation").trim();
						var isAnimated = animation!="";
						var targetType = buttonComputedStyles.getPropertyValue(self.prefix+"action-type").trim();
						var actionTarget = self.application ? null : self.getElement(actionTargetValue);
						var actionTargetStyles = actionTarget ? actionTarget.style : null;

						if (actionTargetStyles) {
							actionTargetStyles.setProperty("animation", animation);
						}

						if ("stopImmediatePropagation" in event) {
							event.stopImmediatePropagation();
						}
					}

					if (self.application==false || targetType=="page") {
						document.location.href = "./" + actionTargetValue;
						return;
					}

					// remove any current overlays
					if (self.currentOverlay) {

						// act as switch if same button
						if (self.currentOverlay==actionTarget || self.currentOverlay==null) {
							if (self.lastTrigger==button) {
								self.removeOverlay(isAnimated);
								return;
							}
						}
						else {
							self.removeOverlay(isAnimated);
						}
					}

					if (reparent) {
						view = self.getElementView(button);
						if (view) {
							view.appendChild(overlay);
						}
					}

					if (query) {
						//self.setElementAnimation(overlay, null);
						//overlay.style.animation = animation;
						self.enableMediaQuery(query);

						var display = overlay && overlay.style.display;

						if (overlay && display=="" || display=="none") {
							overlay.style.display = "block";
							//self.setViewOptions(overlay);
						}

						// add animation defined in event target style declaration
						if (animation && self.supportAnimations) {
							self.fadeIn(overlay, false, animation);
						}
					}
					else if (id) {

						display = window.getComputedStyle(overlay).getPropertyValue("display");

						if (display=="" || display=="none") {
							overlay.style.display = "block";
						}

						// add animation defined in event target style declaration
						if (animation && self.supportAnimations) {
							self.fadeIn(overlay, false, animation);
						}
					}

					// do not set x or y position if centering
					var horizontal = self.prefix + "center-horizontally";
					var vertical = self.prefix + "center-vertically";
					var style = overlay.style;
					var transform = [];

					centerHorizontally = self.getIsStyleDefined(id, horizontal) ? self.getViewPreferenceBoolean(overlay, horizontal) : false;
					centerVertically = self.getIsStyleDefined(id, vertical) ? self.getViewPreferenceBoolean(overlay, vertical) : false;
					anchorLeft = self.getIsStyleDefined(id, "left");
					anchorRight = self.getIsStyleDefined(id, "right");
					anchorTop = self.getIsStyleDefined(id, "top");
					anchorBottom = self.getIsStyleDefined(id, "bottom");


					if (self.viewsDictionary[overlay.id] && self.viewsDictionary[overlay.id].styleDeclaration) {
						style = self.viewsDictionary[overlay.id].styleDeclaration.style;
					}

					if (centerHorizontally) {
						style.left = "50%";
						style.transformOrigin = "0 0";
						transform.push("translateX(-50%)");
					}
					else if (anchorRight && anchorLeft) {
						style.left = x + "px";
					}
					else if (anchorRight) {
						//style.right = x + "px";
					}
					else {
						style.left = x + "px";
					}

					if (centerVertically) {
						style.top = "50%";
						transform.push("translateY(-50%)");
						style.transformOrigin = "0 0";
					}
					else if (anchorTop && anchorBottom) {
						style.top = y + "px";
					}
					else if (anchorBottom) {
						//style.bottom = y + "px";
					}
					else {
						style.top = y + "px";
					}

					if (transform.length) {
						style.transform = transform.join(" ");
					}

					self.currentOverlay = overlay;
					self.lastTrigger = button;
				}

				self.goBack = function() {
					if (self.currentOverlay) {
						self.removeOverlay();
					}
					else if (self.lastView) {
						self.goToView(self.lastView.id);
					}
				}

				self.removeOverlay = function(animate) {
					var overlay = self.currentOverlay;
					animate = animate===false ? false : true;

					if (overlay) {
						var style = overlay.style;

						if (style.animation && self.supportAnimations && animate) {
							self.reverseAnimation(overlay, true);

							var duration = self.getAnimationDuration(style.animation, true);

							setTimeout(function() {
								self.setElementAnimation(overlay, null);
								self.hideOverlay(overlay);
								self.currentOverlay = null;
							}, duration);
						}
						else {
							self.setElementAnimation(overlay, null);
							self.hideOverlay(overlay);
							self.currentOverlay = null;
						}
					}
				}

				/**
				 * Reverse the animation and hide after
				 * @param {Object} target element with animation
				 * @param {Boolean} hide hide after animation ends
				 */
				self.reverseAnimation = function(target, hide) {
					var lastAnimation = null;
					var style = target.style;

					style.animationPlayState = "paused";
					lastAnimation = style.animation;
					style.animation = null;
					style.animationPlayState = "paused";

					if (hide) {
						//target.addEventListener("animationend", self.animationEndHideHandler);

						var duration = self.getAnimationDuration(lastAnimation, true);
						var isOverlay = self.isOverlay(target);

						setTimeout(function() {
							self.setElementAnimation(target, null);

							if (isOverlay) {
								self.hideOverlay(target);
							}
							else {
								self.hideView(target);
							}
						}, duration);
					}

					setTimeout(function() {
						style.animation = lastAnimation;
						style.animationPlayState = "paused";
						style.animationDirection = "reverse";
						style.animationPlayState = "running";
					}, 30);
				}

				self.animationEndHandler = function(event) {
					var target = event.currentTarget;
					self.dispatchEvent(new Event(event.type));
				}

				self.isOverlay = function(view) {
					var result = view ? self.getViewPreferenceBoolean(view, self.prefix + "is-overlay") : false;

					return result;
				}

				self.animationEndHideHandler = function(event) {
					var target = event.currentTarget;
					self.setViewVariables(null, target);
					self.hideView(target);
					target.removeEventListener("animationend", self.animationEndHideHandler);
				}

				self.animationEndShowHandler = function(event) {
					var target = event.currentTarget;
					target.removeEventListener("animationend", self.animationEndShowHandler);
				}

				self.setViewOptions = function(view) {

					if (view) {
						self.minimumScale = self.getViewPreferenceValue(view, self.prefix + "minimum-scale");
						self.maximumScale = self.getViewPreferenceValue(view, self.prefix + "maximum-scale");
						self.scaleViewsToFit = self.getViewPreferenceBoolean(view, self.prefix + "scale-to-fit");
						self.scaleToFitType = self.getViewPreferenceValue(view, self.prefix + "scale-to-fit-type");
						self.scaleToFitOnDoubleClick = self.getViewPreferenceBoolean(view, self.prefix + "scale-on-double-click");
						self.actualSizeOnDoubleClick = self.getViewPreferenceBoolean(view, self.prefix + "actual-size-on-double-click");
						self.scaleViewsOnResize = self.getViewPreferenceBoolean(view, self.prefix + "scale-on-resize");
						self.enableScaleUp = self.getViewPreferenceBoolean(view, self.prefix + "enable-scale-up");
						self.centerHorizontally = self.getViewPreferenceBoolean(view, self.prefix + "center-horizontally");
						self.centerVertically = self.getViewPreferenceBoolean(view, self.prefix + "center-vertically");
						self.navigationOnKeypress = self.getViewPreferenceBoolean(view, self.prefix + "navigate-on-keypress");
						self.showViewName = self.getViewPreferenceBoolean(view, self.prefix + "show-view-name");
						self.refreshPageForChanges = self.getViewPreferenceBoolean(view, self.prefix + "refresh-for-changes");
						self.refreshPageForChangesInterval = self.getViewPreferenceValue(view, self.prefix + "refresh-interval");
						self.showNavigationControls = self.getViewPreferenceBoolean(view, self.prefix + "show-navigation-controls");
						self.scaleViewSlider = self.getViewPreferenceBoolean(view, self.prefix + "show-scale-controls");
						self.enableDeepLinking = self.getViewPreferenceBoolean(view, self.prefix + "enable-deep-linking");
						self.singlePageApplication = self.getViewPreferenceBoolean(view, self.prefix + "application");
						self.showByMediaQuery = self.getViewPreferenceBoolean(view, self.prefix + "show-by-media-query");
						self.showUpdateNotification = document.cookie!="" ? document.cookie.indexOf(self.pageRefreshedName)!=-1 : false;
						self.imageComparisonDuration = self.getViewPreferenceValue(view, self.prefix + "image-comparison-duration");
						self.supportAnimations = self.getViewPreferenceBoolean(view, self.prefix + "enable-animations", true);

						if (self.scaleViewsToFit) {
							var newScaleValue = self.scaleViewToFit(view);

							if (newScaleValue<0) {
								setTimeout(self.scaleViewToFit, 500, view);
							}
						}
						else {
							self.viewScale = self.getViewScaleValue(view);
							self.viewToFitWidthScale = self.getViewFitToViewportWidthScale(view, self.enableScaleUp)
							self.viewToFitHeightScale = self.getViewFitToViewportScale(view, self.enableScaleUp);
							self.updateSliderValue(self.viewScale);
						}

						if (self.imageComparisonDuration!=null) {
							// todo
						}

						if (self.refreshPageForChangesInterval!=null) {
							self.refreshDuration = Number(self.refreshPageForChangesInterval);
						}
					}
				}

				self.previousView = function(event) {
					var rules = self.getStylesheetRules();
					var view = self.getVisibleView()
					var index = view ? self.getViewIndex(view) : -1;
					var prevQueryIndex = index!=-1 ? index-1 : self.currentQuery.index-1;
					var queryIndex = 0;
					var numberOfRules = rules!=null ? rules.length : 0;

					if (event) {
						event.stopImmediatePropagation();
					}

					if (prevQueryIndex<0) {
						return;
					}

					// loop through rules and hide media queries except selected
					for (var i=0;i<numberOfRules;i++) {
						var rule = rules[i];

						if (rule.media!=null) {

							if (queryIndex==prevQueryIndex) {
								self.currentQuery.mediaText = rule.conditionText;
								self.currentQuery.index = prevQueryIndex;
								self.currentQuery.rule = rule;
								self.enableMediaQuery(rule);
								self.updateViewLabel();
								self.updateURL();
								self.dispatchViewChange();
							}
							else {
								self.disableMediaQuery(rule);
							}

							queryIndex++;
						}
					}
				}

				self.nextView = function(event) {
					var rules = self.getStylesheetRules();
					var view = self.getVisibleView();
					var index = view ? self.getViewIndex(view) : -1;
					var nextQueryIndex = index!=-1 ? index+1 : self.currentQuery.index+1;
					var queryIndex = 0;
					var numberOfRules = rules!=null ? rules.length : 0;
					var numberOfMediaQueries = self.getNumberOfMediaRules();

					if (event) {
						event.stopImmediatePropagation();
					}

					if (nextQueryIndex>=numberOfMediaQueries) {
						return;
					}

					// loop through rules and hide media queries except selected
					for (var i=0;i<numberOfRules;i++) {
						var rule = rules[i];

						if (rule.media!=null) {

							if (queryIndex==nextQueryIndex) {
								self.currentQuery.mediaText = rule.conditionText;
								self.currentQuery.index = nextQueryIndex;
								self.currentQuery.rule = rule;
								self.enableMediaQuery(rule);
								self.updateViewLabel();
								self.updateURL();
								self.dispatchViewChange();
							}
							else {
								self.disableMediaQuery(rule);
							}

							queryIndex++;
						}
					}
				}

				/**
				 * Enables a view via media query
				 */
				self.enableMediaQuery = function(rule) {

					try {
						rule.media.mediaText = self.inclusionQuery;
					}
					catch(error) {
						//self.log(error);
						rule.conditionText = self.inclusionQuery;
					}
				}

				self.disableMediaQuery = function(rule) {

					try {
						rule.media.mediaText = self.exclusionQuery;
					}
					catch(error) {
						rule.conditionText = self.exclusionQuery;
					}
				}

				self.dispatchViewChange = function() {
					try {
						var event = new Event(self.NAVIGATION_CHANGE);
						window.dispatchEvent(event);
					}
					catch (error) {
						// In IE 11: Object doesn't support this action
					}
				}

				self.getNumberOfMediaRules = function() {
					var rules = self.getStylesheetRules();
					var numberOfRules = rules ? rules.length : 0;
					var numberOfQueries = 0;

					for (var i=0;i<numberOfRules;i++) {
						if (rules[i].media!=null) { numberOfQueries++; }
					}

					return numberOfQueries;
				}

				/////////////////////////////////////////
				// VIEW SCALE
				/////////////////////////////////////////

				self.sliderChangeHandler = function(event) {
					var value = self.getShortNumber(event.currentTarget.value/100);
					var view = self.getVisibleView();
					self.setViewScaleValue(view, false, value, true);
				}

				self.updateSliderValue = function(scale) {
					var slider = document.getElementById(self.viewScaleSliderId);
					var tooltip = parseInt(scale * 100 + "") + "%";
					var inputType;
					var inputValue;

					if (slider) {
						inputValue = self.getShortNumber(scale * 100);
						if (inputValue!=slider["value"]) {
							slider["value"] = inputValue;
						}
						inputType = slider.getAttributeNS(null, "type");

						if (inputType!="range") {
							// input range is not supported
							slider.style.display = "none";
						}

						self.setTooltip(slider, tooltip);
					}
				}

				self.viewChangeHandler = function(event) {
					var view = self.getVisibleView();
					var matrix = view ? getComputedStyle(view).transform : null;

					if (matrix) {
						self.viewScale = self.getViewScaleValue(view);

						var scaleNeededToFit = self.getViewFitToViewportScale(view);
						var isViewLargerThanViewport = scaleNeededToFit<1;

						// scale large view to fit if scale to fit is enabled
						if (self.scaleViewsToFit) {
							self.scaleViewToFit(view);
						}
						else {
							self.updateSliderValue(self.viewScale);
						}
					}
				}

				self.getViewScaleValue = function(view) {
					var matrix = getComputedStyle(view).transform;

					if (matrix) {
						var matrixArray = matrix.replace("matrix(", "").split(",");
						var scaleX = parseFloat(matrixArray[0]);
						var scaleY = parseFloat(matrixArray[3]);
						var scale = Math.min(scaleX, scaleY);
					}

					return scale;
				}

				/**
				 * Scales view to scale.
				 * @param {Object} view view to scale. views are in views array
				 * @param {Boolean} scaleToFit set to true to scale to fit. set false to use desired scale value
				 * @param {Number} desiredScale scale to define. not used if scale to fit is false
				 * @param {Boolean} isSliderChange indicates if slider is callee
				 */
				self.setViewScaleValue = function(view, scaleToFit, desiredScale, isSliderChange) {
					var enableScaleUp = self.enableScaleUp;
					var scaleToFitType = self.scaleToFitType;
					var minimumScale = self.minimumScale;
					var maximumScale = self.maximumScale;
					var hasMinimumScale = !isNaN(minimumScale) && minimumScale!="";
					var hasMaximumScale = !isNaN(maximumScale) && maximumScale!="";
					var scaleNeededToFit = self.getViewFitToViewportScale(view, enableScaleUp);
					var scaleNeededToFitWidth = self.getViewFitToViewportWidthScale(view, enableScaleUp);
					var scaleNeededToFitHeight = self.getViewFitToViewportHeightScale(view, enableScaleUp);
					var scaleToFitFull = self.getViewFitToViewportScale(view, true);
					var scaleToFitFullWidth = self.getViewFitToViewportWidthScale(view, true);
					var scaleToFitFullHeight = self.getViewFitToViewportHeightScale(view, true);
					var scaleToWidth = scaleToFitType=="width";
					var scaleToHeight = scaleToFitType=="height";
					var shrunkToFit = false;
					var topPosition = null;
					var leftPosition = null;
					var translateY = null;
					var translateX = null;
					var transformValue = "";
					var canCenterVertically = true;
					var canCenterHorizontally = true;
					var style = view.style;

					if (view && self.viewsDictionary[view.id] && self.viewsDictionary[view.id].styleDeclaration) {
						style = self.viewsDictionary[view.id].styleDeclaration.style;
					}

					if (scaleToFit && isSliderChange!=true) {
						if (scaleToFitType=="fit" || scaleToFitType=="") {
							desiredScale = scaleNeededToFit;
						}
						else if (scaleToFitType=="width") {
							desiredScale = scaleNeededToFitWidth;
						}
						else if (scaleToFitType=="height") {
							desiredScale = scaleNeededToFitHeight;
						}
					}
					else {
						if (isNaN(desiredScale)) {
							desiredScale = 1;
						}
					}

					self.updateSliderValue(desiredScale);

					// scale to fit width
					if (scaleToWidth && scaleToHeight==false) {
						canCenterVertically = scaleNeededToFitHeight>=scaleNeededToFitWidth;
						canCenterHorizontally = scaleNeededToFitWidth>=1 && enableScaleUp==false;

						if (isSliderChange) {
							canCenterHorizontally = desiredScale<scaleToFitFullWidth;
						}
						else if (scaleToFit) {
							desiredScale = scaleNeededToFitWidth;
						}

						if (hasMinimumScale) {
							desiredScale = Math.max(desiredScale, Number(minimumScale));
						}

						if (hasMaximumScale) {
							desiredScale = Math.min(desiredScale, Number(maximumScale));
						}

						desiredScale = self.getShortNumber(desiredScale);

						canCenterHorizontally = self.canCenterHorizontally(view, "width", enableScaleUp, desiredScale, minimumScale, maximumScale);
						canCenterVertically = self.canCenterVertically(view, "width", enableScaleUp, desiredScale, minimumScale, maximumScale);

						if (desiredScale>1 && (enableScaleUp || isSliderChange)) {
							transformValue = "scale(" + desiredScale + ")";
						}
						else if (desiredScale>=1 && enableScaleUp==false) {
							transformValue = "scale(" + 1 + ")";
						}
						else {
							transformValue = "scale(" + desiredScale + ")";
						}

						if (self.centerVertically) {
							if (canCenterVertically) {
								translateY = "-50%";
								topPosition = "50%";
							}
							else {
								translateY = "0";
								topPosition = "0";
							}

							if (style.top != topPosition) {
								style.top = topPosition + "";
							}

							if (canCenterVertically) {
								transformValue += " translateY(" + translateY+ ")";
							}
						}

						if (self.centerHorizontally) {
							if (canCenterHorizontally) {
								translateX = "-50%";
								leftPosition = "50%";
							}
							else {
								translateX = "0";
								leftPosition = "0";
							}

							if (style.left != leftPosition) {
								style.left = leftPosition + "";
							}

							if (canCenterHorizontally) {
								transformValue += " translateX(" + translateX+ ")";
							}
						}

						style.transformOrigin = "0 0";
						style.transform = transformValue;

						self.viewScale = desiredScale;
						self.viewToFitWidthScale = scaleNeededToFitWidth;
						self.viewToFitHeightScale = scaleNeededToFitHeight;
						self.viewLeft = leftPosition;
						self.viewTop = topPosition;

						return desiredScale;
					}

					// scale to fit height
					if (scaleToHeight && scaleToWidth==false) {
						//canCenterVertically = scaleNeededToFitHeight>=scaleNeededToFitWidth;
						//canCenterHorizontally = scaleNeededToFitHeight<=scaleNeededToFitWidth && enableScaleUp==false;
						canCenterVertically = scaleNeededToFitHeight>=scaleNeededToFitWidth;
						canCenterHorizontally = scaleNeededToFitWidth>=1 && enableScaleUp==false;

						if (isSliderChange) {
							canCenterHorizontally = desiredScale<scaleToFitFullHeight;
						}
						else if (scaleToFit) {
							desiredScale = scaleNeededToFitHeight;
						}

						if (hasMinimumScale) {
							desiredScale = Math.max(desiredScale, Number(minimumScale));
						}

						if (hasMaximumScale) {
							desiredScale = Math.min(desiredScale, Number(maximumScale));
							//canCenterVertically = desiredScale>=scaleNeededToFitHeight && enableScaleUp==false;
						}

						desiredScale = self.getShortNumber(desiredScale);

						canCenterHorizontally = self.canCenterHorizontally(view, "height", enableScaleUp, desiredScale, minimumScale, maximumScale);
						canCenterVertically = self.canCenterVertically(view, "height", enableScaleUp, desiredScale, minimumScale, maximumScale);

						if (desiredScale>1 && (enableScaleUp || isSliderChange)) {
							transformValue = "scale(" + desiredScale + ")";
						}
						else if (desiredScale>=1 && enableScaleUp==false) {
							transformValue = "scale(" + 1 + ")";
						}
						else {
							transformValue = "scale(" + desiredScale + ")";
						}

						if (self.centerHorizontally) {
							if (canCenterHorizontally) {
								translateX = "-50%";
								leftPosition = "50%";
							}
							else {
								translateX = "0";
								leftPosition = "0";
							}

							if (style.left != leftPosition) {
								style.left = leftPosition + "";
							}

							if (canCenterHorizontally) {
								transformValue += " translateX(" + translateX+ ")";
							}
						}

						if (self.centerVertically) {
							if (canCenterVertically) {
								translateY = "-50%";
								topPosition = "50%";
							}
							else {
								translateY = "0";
								topPosition = "0";
							}

							if (style.top != topPosition) {
								style.top = topPosition + "";
							}

							if (canCenterVertically) {
								transformValue += " translateY(" + translateY+ ")";
							}
						}

						style.transformOrigin = "0 0";
						style.transform = transformValue;

						self.viewScale = desiredScale;
						self.viewToFitWidthScale = scaleNeededToFitWidth;
						self.viewToFitHeightScale = scaleNeededToFitHeight;
						self.viewLeft = leftPosition;
						self.viewTop = topPosition;

						return scaleNeededToFitHeight;
					}

					if (scaleToFitType=="fit") {
						//canCenterVertically = scaleNeededToFitHeight>=scaleNeededToFitWidth;
						//canCenterHorizontally = scaleNeededToFitWidth>=scaleNeededToFitHeight;
						canCenterVertically = scaleNeededToFitHeight>=scaleNeededToFit;
						canCenterHorizontally = scaleNeededToFitWidth>=scaleNeededToFit;

						if (hasMinimumScale) {
							desiredScale = Math.max(desiredScale, Number(minimumScale));
						}

						desiredScale = self.getShortNumber(desiredScale);

						if (isSliderChange || scaleToFit==false) {
							canCenterVertically = scaleToFitFullHeight>=desiredScale;
							canCenterHorizontally = desiredScale<scaleToFitFullWidth;
						}
						else if (scaleToFit) {
							desiredScale = scaleNeededToFit;
						}

						transformValue = "scale(" + desiredScale + ")";

						//canCenterHorizontally = self.canCenterHorizontally(view, "fit", false, desiredScale);
						//canCenterVertically = self.canCenterVertically(view, "fit", false, desiredScale);

						if (self.centerVertically) {
							if (canCenterVertically) {
								translateY = "-50%";
								topPosition = "50%";
							}
							else {
								translateY = "0";
								topPosition = "0";
							}

							if (style.top != topPosition) {
								style.top = topPosition + "";
							}

							if (canCenterVertically) {
								transformValue += " translateY(" + translateY+ ")";
							}
						}

						if (self.centerHorizontally) {
							if (canCenterHorizontally) {
								translateX = "-50%";
								leftPosition = "50%";
							}
							else {
								translateX = "0";
								leftPosition = "0";
							}

							if (style.left != leftPosition) {
								style.left = leftPosition + "";
							}

							if (canCenterHorizontally) {
								transformValue += " translateX(" + translateX+ ")";
							}
						}

						style.transformOrigin = "0 0";
						style.transform = transformValue;

						self.viewScale = desiredScale;
						self.viewToFitWidthScale = scaleNeededToFitWidth;
						self.viewToFitHeightScale = scaleNeededToFitHeight;
						self.viewLeft = leftPosition;
						self.viewTop = topPosition;

						self.updateSliderValue(desiredScale);

						return desiredScale;
					}

					if (scaleToFitType=="default" || scaleToFitType=="") {
						desiredScale = 1;

						if (hasMinimumScale) {
							desiredScale = Math.max(desiredScale, Number(minimumScale));
						}
						if (hasMaximumScale) {
							desiredScale = Math.min(desiredScale, Number(maximumScale));
						}

						canCenterHorizontally = self.canCenterHorizontally(view, "none", false, desiredScale, minimumScale, maximumScale);
						canCenterVertically = self.canCenterVertically(view, "none", false, desiredScale, minimumScale, maximumScale);

						if (self.centerVertically) {
							if (canCenterVertically) {
								translateY = "-50%";
								topPosition = "50%";
							}
							else {
								translateY = "0";
								topPosition = "0";
							}

							if (style.top != topPosition) {
								style.top = topPosition + "";
							}

							if (canCenterVertically) {
								transformValue += " translateY(" + translateY+ ")";
							}
						}

						if (self.centerHorizontally) {
							if (canCenterHorizontally) {
								translateX = "-50%";
								leftPosition = "50%";
							}
							else {
								translateX = "0";
								leftPosition = "0";
							}

							if (style.left != leftPosition) {
								style.left = leftPosition + "";
							}

							if (canCenterHorizontally) {
								transformValue += " translateX(" + translateX+ ")";
							}
							else {
								transformValue += " translateX(" + 0 + ")";
							}
						}

						style.transformOrigin = "0 0";
						style.transform = transformValue;


						self.viewScale = desiredScale;
						self.viewToFitWidthScale = scaleNeededToFitWidth;
						self.viewToFitHeightScale = scaleNeededToFitHeight;
						self.viewLeft = leftPosition;
						self.viewTop = topPosition;

						self.updateSliderValue(desiredScale);

						return desiredScale;
					}
				}

				/**
				 * Returns true if view can be centered horizontally
				 * @param {HTMLElement} view view
				 * @param {String} type type of scaling - width, height, all, none
				 * @param {Boolean} scaleUp if scale up enabled
				 * @param {Number} scale target scale value
				 */
				self.canCenterHorizontally = function(view, type, scaleUp, scale, minimumScale, maximumScale) {
					var scaleNeededToFit = self.getViewFitToViewportScale(view, scaleUp);
					var scaleNeededToFitHeight = self.getViewFitToViewportHeightScale(view, scaleUp);
					var scaleNeededToFitWidth = self.getViewFitToViewportWidthScale(view, scaleUp);
					var canCenter = false;
					var minScale;

					type = type==null ? "none" : type;
					scale = scale==null ? scale : scaleNeededToFitWidth;
					scaleUp = scaleUp == null ? false : scaleUp;

					if (type=="width") {

						if (scaleUp && maximumScale==null) {
							canCenter = false;
						}
						else if (scaleNeededToFitWidth>=1) {
							canCenter = true;
						}
					}
					else if (type=="height") {
						minScale = Math.min(1, scaleNeededToFitHeight);
						if (minimumScale!="" && maximumScale!="") {
							minScale = Math.max(minimumScale, Math.min(maximumScale, scaleNeededToFitHeight));
						}
						else {
							if (minimumScale!="") {
								minScale = Math.max(minimumScale, scaleNeededToFitHeight);
							}
							if (maximumScale!="") {
								minScale = Math.max(minimumScale, Math.min(maximumScale, scaleNeededToFitHeight));
							}
						}

						if (scaleUp && maximumScale=="") {
							canCenter = false;
						}
						else if (scaleNeededToFitWidth>=minScale) {
							canCenter = true;
						}
					}
					else if (type=="fit") {
						canCenter = scaleNeededToFitWidth>=scaleNeededToFit;
					}
					else {
						if (scaleUp) {
							canCenter = false;
						}
						else if (scaleNeededToFitWidth>=1) {
							canCenter = true;
						}
					}

					self.horizontalScrollbarsNeeded = canCenter;

					return canCenter;
				}

				/**
				 * Returns true if view can be centered horizontally
				 * @param {HTMLElement} view view to scale
				 * @param {String} type type of scaling
				 * @param {Boolean} scaleUp if scale up enabled
				 * @param {Number} scale target scale value
				 */
				self.canCenterVertically = function(view, type, scaleUp, scale, minimumScale, maximumScale) {
					var scaleNeededToFit = self.getViewFitToViewportScale(view, scaleUp);
					var scaleNeededToFitWidth = self.getViewFitToViewportWidthScale(view, scaleUp);
					var scaleNeededToFitHeight = self.getViewFitToViewportHeightScale(view, scaleUp);
					var canCenter = false;
					var minScale;

					type = type==null ? "none" : type;
					scale = scale==null ? 1 : scale;
					scaleUp = scaleUp == null ? false : scaleUp;

					if (type=="width") {
						canCenter = scaleNeededToFitHeight>=scaleNeededToFitWidth;
					}
					else if (type=="height") {
						minScale = Math.max(minimumScale, Math.min(maximumScale, scaleNeededToFit));
						canCenter = scaleNeededToFitHeight>=minScale;
					}
					else if (type=="fit") {
						canCenter = scaleNeededToFitHeight>=scaleNeededToFit;
					}
					else {
						if (scaleUp) {
							canCenter = false;
						}
						else if (scaleNeededToFitHeight>=1) {
							canCenter = true;
						}
					}

					self.verticalScrollbarsNeeded = canCenter;

					return canCenter;
				}

				self.getViewFitToViewportScale = function(view, scaleUp) {
					var enableScaleUp = scaleUp;
					var availableWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
					var availableHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
					var elementWidth = parseFloat(getComputedStyle(view, "style").width);
					var elementHeight = parseFloat(getComputedStyle(view, "style").height);
					var newScale = 1;

					// if element is not added to the document computed values are NaN
					if (isNaN(elementWidth) || isNaN(elementHeight)) {
						return newScale;
					}

					availableWidth -= self.horizontalPadding;
					availableHeight -= self.verticalPadding;

					if (enableScaleUp) {
						newScale = Math.min(availableHeight/elementHeight, availableWidth/elementWidth);
					}
					else if (elementWidth > availableWidth || elementHeight > availableHeight) {
						newScale = Math.min(availableHeight/elementHeight, availableWidth/elementWidth);
					}

					return newScale;
				}

				self.getViewFitToViewportWidthScale = function(view, scaleUp) {
					// need to get browser viewport width when element
					var isParentWindow = view && view.parentNode && view.parentNode===document.body;
					var enableScaleUp = scaleUp;
					var availableWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
					var elementWidth = parseFloat(getComputedStyle(view, "style").width);
					var newScale = 1;

					// if element is not added to the document computed values are NaN
					if (isNaN(elementWidth)) {
						return newScale;
					}

					availableWidth -= self.horizontalPadding;

					if (enableScaleUp) {
						newScale = availableWidth/elementWidth;
					}
					else if (elementWidth > availableWidth) {
						newScale = availableWidth/elementWidth;
					}

					return newScale;
				}

				self.getViewFitToViewportHeightScale = function(view, scaleUp) {
					var enableScaleUp = scaleUp;
					var availableHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
					var elementHeight = parseFloat(getComputedStyle(view, "style").height);
					var newScale = 1;

					// if element is not added to the document computed values are NaN
					if (isNaN(elementHeight)) {
						return newScale;
					}

					availableHeight -= self.verticalPadding;

					if (enableScaleUp) {
						newScale = availableHeight/elementHeight;
					}
					else if (elementHeight > availableHeight) {
						newScale = availableHeight/elementHeight;
					}

					return newScale;
				}

				self.keypressHandler = function(event) {
					var rightKey = 39;
					var leftKey = 37;

					// listen for both events
					if (event.type=="keypress") {
						window.removeEventListener("keyup", self.keypressHandler);
					}
					else {
						window.removeEventListener("keypress", self.keypressHandler);
					}

					if (self.showNavigationControls) {
						if (self.navigationOnKeypress) {
							if (event.keyCode==rightKey) {
								self.nextView();
							}
							if (event.keyCode==leftKey) {
								self.previousView();
							}
						}
					}
					else if (self.navigationOnKeypress) {
						if (event.keyCode==rightKey) {
							self.nextView();
						}
						if (event.keyCode==leftKey) {
							self.previousView();
						}
					}
				}

				///////////////////////////////////
				// GENERAL FUNCTIONS
				///////////////////////////////////

				self.getViewById = function(id) {
					id = id ? id.replace("#", "") : "";
					var view = self.viewIds.indexOf(id)!=-1 && self.getElement(id);
					return view;
				}

				self.getViewIds = function() {
					var viewIds = self.getViewPreferenceValue(document.body, self.prefix + "view-ids");
					var viewId = null;

					viewIds = viewIds!=null && viewIds!="" ? viewIds.split(",") : [];

					if (viewIds.length==0) {
						viewId = self.getViewPreferenceValue(document.body, self.prefix + "view-id");
						viewIds = viewId ? [viewId] : [];
					}

					return viewIds;
				}

				self.getInitialViewId = function() {
					var viewId = self.getViewPreferenceValue(document.body, self.prefix + "view-id");
					return viewId;
				}

				self.getApplicationStylesheet = function() {
					var stylesheetId = self.getViewPreferenceValue(document.body, self.prefix + "stylesheet-id");
					self.applicationStylesheet = document.getElementById("applicationStylesheet");
					return self.applicationStylesheet.sheet;
				}

				self.getVisibleView = function() {
					var viewIds = self.getViewIds();

					for (var i=0;i<viewIds.length;i++) {
						var viewId = viewIds[i].replace(/[\#?\.?](.*)/, "$" + "1");
						var view = self.getElement(viewId);
						var postName = "_Class";

						if (view==null && viewId && viewId.lastIndexOf(postName)!=-1) {
							view = self.getElement(viewId.replace(postName, ""));
						}

						if (view) {
							var display = getComputedStyle(view).display;

							if (display=="block" || display=="flex") {
								return view;
							}
						}
					}

					return null;
				}

				self.getVisibleViews = function() {
					var viewIds = self.getViewIds();
					var views = [];

					for (var i=0;i<viewIds.length;i++) {
						var viewId = viewIds[i].replace(/[\#?\.?](.*)/, "$" + "1");
						var view = self.getElement(viewId);
						var postName = "_Class";

						if (view==null && viewId && viewId.lastIndexOf(postName)!=-1) {
							view = self.getElement(viewId.replace(postName, ""));
						}

						if (view) {
							var display = getComputedStyle(view).display;

							if (display=="none") {
								continue;
							}

							if (display=="block" || display=="flex") {
								views.push(view);
							}
						}
					}

					return views;
				}

				self.getStateNameByViewId = function(id) {
					var state = self.viewsDictionary[id];
					return state && state.stateName;
				}

				self.getMatchingViews = function(ids) {
					var views = self.addedViews.slice(0);
					var matchingViews = [];

					if (self.showByMediaQuery) {
						for (let index = 0; index < views.length; index++) {
							var viewId = views[index];
							var state = self.viewsDictionary[viewId];
							var rule = state && state.rule;
							var matchResults = window.matchMedia(rule.conditionText);
							var view = self.views[viewId];

							if (matchResults.matches) {
								if (ids==true) {
									matchingViews.push(viewId);
								}
								else {
									matchingViews.push(view);
								}
							}
						}
					}

					return matchingViews;
				}

				self.ruleMatchesQuery = function(rule) {
					var result = window.matchMedia(rule.conditionText);
					return result.matches;
				}

				self.getViewsByStateName = function(stateName, matchQuery) {
					var views = self.addedViews.slice(0);
					var matchingViews = [];

					if (self.showByMediaQuery) {

						// find state name
						for (let index = 0; index < views.length; index++) {
							var viewId = views[index];
							var state = self.viewsDictionary[viewId];
							var rule = state.rule;
							var mediaRule = state.mediaRule;
							var view = self.views[viewId];
							var viewStateName = self.getStyleRuleValue(mediaRule, self.STATE_NAME, state);
							var stateFoundAtt = view.getAttribute(self.STATE_NAME)==state;
							var matchesResults = false;

							if (viewStateName==stateName) {
								if (matchQuery) {
									matchesResults = self.ruleMatchesQuery(rule);

									if (matchesResults) {
										matchingViews.push(view);
									}
								}
								else {
									matchingViews.push(view);
								}
							}
						}
					}

					return matchingViews;
				}

				self.getInitialView = function() {
					var viewId = self.getInitialViewId();
					viewId = viewId.replace(/[\#?\.?](.*)/, "$" + "1");
					var view = self.getElement(viewId);
					var postName = "_Class";

					if (view==null && viewId && viewId.lastIndexOf(postName)!=-1) {
						view = self.getElement(viewId.replace(postName, ""));
					}

					return view;
				}

				self.getViewIndex = function(view) {
					var viewIds = self.getViewIds();
					var id = view ? view.id : null;
					var index = id && viewIds ? viewIds.indexOf(id) : -1;

					return index;
				}

				self.syncronizeViewToURL = function() {
					var fragment = self.getHashFragment();

					if (self.showByMediaQuery) {
						var stateName = fragment;

						if (stateName==null || stateName=="") {
							var initialView = self.getInitialView();
							stateName = initialView ? self.getStateNameByViewId(initialView.id) : null;
						}

						self.showMediaQueryViewsByState(stateName);
						return;
					}

					var view = self.getViewById(fragment);
					var index = view ? self.getViewIndex(view) : 0;
					if (index==-1) index = 0;
					var currentView = self.hideViews(index);

					if (self.supportsPopState && currentView) {

						if (fragment==null) {
							window.history.replaceState({name:currentView.id}, null, "#"+ currentView.id);
						}
						else {
							window.history.pushState({name:currentView.id}, null, "#"+ currentView.id);
						}
					}

					self.setViewVariables(view);
					return view;
				}

				/**
				 * Set the currentView or currentOverlay properties and set the lastView or lastOverlay properties
				 */
				self.setViewVariables = function(view, overlay, parentView) {
					if (view) {
						if (self.currentView) {
							self.lastView = self.currentView;
						}
						self.currentView = view;
					}

					if (overlay) {
						if (self.currentOverlay) {
							self.lastOverlay = self.currentOverlay;
						}
						self.currentOverlay = overlay;
					}
				}

				self.getViewPreferenceBoolean = function(view, property, altValue) {
					var computedStyle = window.getComputedStyle(view);
					var value = computedStyle.getPropertyValue(property);
					var type = typeof value;

					if (value=="true" || (type=="string" && value.indexOf("true")!=-1)) {
						return true;
					}
					else if (value=="" && arguments.length==3) {
						return altValue;
					}

					return false;
				}

				self.getViewPreferenceValue = function(view, property, defaultValue) {
					var value = window.getComputedStyle(view).getPropertyValue(property);

					if (value===undefined) {
						return defaultValue;
					}

					value = value.replace(/^[\s\"]*/, "");
					value = value.replace(/[\s\"]*$/, "");
					value = value.replace(/^[\s"]*(.*?)[\s"]*$/, function (match, capture) {
						return capture;
					});

					return value;
				}

				self.getStyleRuleValue = function(cssRule, property) {
					var value = cssRule ? cssRule.style.getPropertyValue(property) : null;

					if (value===undefined) {
						return null;
					}

					value = value.replace(/^[\s\"]*/, "");
					value = value.replace(/[\s\"]*$/, "");
					value = value.replace(/^[\s"]*(.*?)[\s"]*$/, function (match, capture) {
						return capture;
					});

					return value;
				}

				/**
				 * Get the first defined value of property. Returns empty string if not defined
				 * @param {String} id id of element
				 * @param {String} property
				 */
				self.getCSSPropertyValueForElement = function(id, property) {
					var styleSheets = document.styleSheets;
					var numOfStylesheets = styleSheets.length;
					var values = [];
					var selectorIDText = "#" + id;
					var selectorClassText = "." + id + "_Class";
					var value;

					for(var i=0;i<numOfStylesheets;i++) {
						var styleSheet = styleSheets[i];
						var cssRules = self.getStylesheetRules(styleSheet);
						var numOfCSSRules = cssRules.length;
						var cssRule;

						for (var j=0;j<numOfCSSRules;j++) {
							cssRule = cssRules[j];

							if (cssRule.media) {
								var mediaRules = cssRule.cssRules;
								var numOfMediaRules = mediaRules ? mediaRules.length : 0;

								for(var k=0;k<numOfMediaRules;k++) {
									var mediaRule = mediaRules[k];

									if (mediaRule.selectorText==selectorIDText || mediaRule.selectorText==selectorClassText) {

										if (mediaRule.style && mediaRule.style.getPropertyValue(property)!="") {
											value = mediaRule.style.getPropertyValue(property);
											values.push(value);
										}
									}
								}
							}
							else {

								if (cssRule.selectorText==selectorIDText || cssRule.selectorText==selectorClassText) {
									if (cssRule.style && cssRule.style.getPropertyValue(property)!="") {
										value = cssRule.style.getPropertyValue(property);
										values.push(value);
									}
								}
							}
						}
					}

					return values.pop();
				}

				self.getIsStyleDefined = function(id, property) {
					var value = self.getCSSPropertyValueForElement(id, property);
					return value!==undefined && value!="";
				}

				self.collectViews = function() {
					var viewIds = self.getViewIds();

					for (let index = 0; index < viewIds.length; index++) {
						const id = viewIds[index];
						const view = self.getElement(id);
						self.views[id] = view;
					}

					self.viewIds = viewIds;
				}

				self.collectOverlays = function() {
					var viewIds = self.getViewIds();
					var ids = [];

					for (let index = 0; index < viewIds.length; index++) {
						const id = viewIds[index];
						const view = self.getViewById(id);
						const isOverlay = view && self.isOverlay(view);

						if (isOverlay) {
							ids.push(id);
							self.overlays[id] = view;
						}
					}

					self.overlayIds = ids;
				}

				self.collectMediaQueries = function() {
					var viewIds = self.getViewIds();
					var styleSheet = self.getApplicationStylesheet();
					var cssRules = self.getStylesheetRules(styleSheet);
					var numOfCSSRules = cssRules ? cssRules.length : 0;
					var cssRule;
					var id = viewIds.length ? viewIds[0]: ""; // single view
					var selectorIDText = "#" + id;
					var selectorClassText = "." + id + "_Class";
					var viewsNotFound = viewIds.slice();
					var viewsFound = [];
					var selectorText = null;
					var property = self.prefix + "view-id";
					var stateName = self.prefix + "state";
					var stateValue = null;
					var view = null;

					for (var j=0;j<numOfCSSRules;j++) {
						cssRule = cssRules[j];

						if (cssRule.media) {
							var mediaRules = cssRule.cssRules;
							var numOfMediaRules = mediaRules ? mediaRules.length : 0;
							var mediaViewInfoFound = false;
							var mediaId = null;

							for(var k=0;k<numOfMediaRules;k++) {
								var mediaRule = mediaRules[k];

								selectorText = mediaRule.selectorText;

								if (selectorText==".mediaViewInfo" && mediaViewInfoFound==false) {

									mediaId = self.getStyleRuleValue(mediaRule, property);
									stateValue = self.getStyleRuleValue(mediaRule, stateName);

									selectorIDText = "#" + mediaId;
									selectorClassText = "." + mediaId + "_Class";
									view = self.getElement(mediaId);

									// prevent duplicates from load and domcontentloaded events
									if (self.addedViews.indexOf(mediaId)==-1) {
										self.addView(view, mediaId, cssRule, mediaRule, stateValue);
									}

									viewsFound.push(mediaId);

									if (viewsNotFound.indexOf(mediaId)!=-1) {
										viewsNotFound.splice(viewsNotFound.indexOf(mediaId));
									}

									mediaViewInfoFound = true;
								}

								if (selectorIDText==selectorText || selectorClassText==selectorText) {
									var styleObject = self.viewsDictionary[mediaId];
									if (styleObject) {
										styleObject.styleDeclaration = mediaRule;
									}
									break;
								}
							}
						}
						else {
							selectorText = cssRule.selectorText;

							if (selectorText==null) continue;

							selectorText = selectorText.replace(/[#|\s|*]?/g, "");

							if (viewIds.indexOf(selectorText)!=-1) {
								view = self.getElement(selectorText);
								self.addView(view, selectorText, cssRule, null, stateValue);

								if (viewsNotFound.indexOf(selectorText)!=-1) {
									viewsNotFound.splice(viewsNotFound.indexOf(selectorText));
								}

								break;
							}
						}
					}

					if (viewsNotFound.length) {
						console.log("Could not find the following views:" + viewsNotFound.join(",") + "");
						console.log("Views found:" + viewsFound.join(",") + "");
					}
				}

				/**
				 * Adds a view
				 * @param {HTMLElement} view view element
				 * @param {String} id id of view element
				 * @param {CSSRule} cssRule of view element
				 * @param {CSSMediaRule} mediaRule media rule of view element
				 * @param {String} stateName name of state if applicable
				 **/
				self.addView = function(view, viewId, cssRule, mediaRule, stateName) {
					var viewData = {};
					viewData.name = viewId;
					viewData.rule = cssRule;
					viewData.id = viewId;
					viewData.mediaRule = mediaRule;
					viewData.stateName = stateName;

					self.views.push(viewData);
					self.addedViews.push(viewId);
					self.viewsDictionary[viewId] = viewData;
					self.mediaQueryDictionary[viewId] = cssRule;
				}

				self.hasView = function(name) {

					if (self.addedViews.indexOf(name)!=-1) {
						return true;
					}
					return false;
				}

				/**
				 * Go to view by id. Views are added in addView()
				 * @param {String} id id of view in current
				 * @param {Boolean} maintainPreviousState if true then do not hide other views
				 * @param {String} parent id of parent view
				 **/
				self.goToView = function(id, maintainPreviousState, parent) {
					var state = self.viewsDictionary[id];

					if (state) {
						if (maintainPreviousState==false || maintainPreviousState==null) {
							self.hideViews();
						}
						self.enableMediaQuery(state.rule);
						self.updateViewLabel();
						self.updateURL();
					}
					else {
						var event = new Event(self.STATE_NOT_FOUND);
						self.stateName = id;
						window.dispatchEvent(event);
					}
				}

				/**
				 * Go to the view in the event targets CSS variable
				 **/
				self.goToTargetView = function(event) {
					var button = event.currentTarget;
					var buttonComputedStyles = getComputedStyle(button);
					var actionTargetValue = buttonComputedStyles.getPropertyValue(self.prefix+"action-target").trim();
					var animation = buttonComputedStyles.getPropertyValue(self.prefix+"animation").trim();
					var targetType = buttonComputedStyles.getPropertyValue(self.prefix+"action-type").trim();
					var targetView = self.application ? null : self.getElement(actionTargetValue);
					var targetState = targetView ? self.getStateNameByViewId(targetView.id) : null;
					var actionTargetStyles = targetView ? targetView.style : null;
					var state = self.viewsDictionary[actionTargetValue];

					// navigate to page
					if (self.application==false || targetType=="page") {
						document.location.href = "./" + actionTargetValue;
						return;
					}

					// if view is found
					if (targetView) {

						if (self.currentOverlay) {
							self.removeOverlay(false);
						}

						if (self.showByMediaQuery) {
							var stateName = targetState;

							if (stateName==null || stateName=="") {
								var initialView = self.getInitialView();
								stateName = initialView ? self.getStateNameByViewId(initialView.id) : null;
							}
							self.showMediaQueryViewsByState(stateName, event);
							return;
						}

						// add animation set in event target style declaration
						if (animation && self.supportAnimations) {
							self.crossFade(self.currentView, targetView, false, animation);
						}
						else {
							self.setViewVariables(self.currentView);
							self.hideViews();
							self.enableMediaQuery(state.rule);
							self.scaleViewIfNeeded(targetView);
							self.centerView(targetView);
							self.updateViewLabel();
							self.updateURL();
						}
					}
					else {
						var stateEvent = new Event(self.STATE_NOT_FOUND);
						self.stateName = name;
						window.dispatchEvent(stateEvent);
					}

					event.stopImmediatePropagation();
				}

				/**
				 * Cross fade between views
				 **/
				self.crossFade = function(from, to, update, animation) {
					var targetIndex = to.parentNode
					var fromIndex = Array.prototype.slice.call(from.parentElement.children).indexOf(from);
					var toIndex = Array.prototype.slice.call(to.parentElement.children).indexOf(to);

					if (from.parentNode==to.parentNode) {
						var reverse = self.getReverseAnimation(animation);
						var duration = self.getAnimationDuration(animation, true);

						// if target view is above (higher index)
						// then fade in target view
						// and after fade in then hide previous view instantly
						if (fromIndex<toIndex) {
							self.setElementAnimation(from, null);
							self.setElementAnimation(to, null);
							self.showViewByMediaQuery(to);
							self.fadeIn(to, update, animation);

							setTimeout(function() {
								self.setElementAnimation(to, null);
								self.setElementAnimation(from, null);
								self.hideView(from);
								self.updateURL();
								self.setViewVariables(to);
								self.updateViewLabel();
							}, duration)
						}
								// if target view is on bottom
								// then show target view instantly
						// and fade out current view
						else if (fromIndex>toIndex) {
							self.setElementAnimation(to, null);
							self.setElementAnimation(from, null);
							self.showViewByMediaQuery(to);
							self.fadeOut(from, update, reverse);

							setTimeout(function() {
								self.setElementAnimation(to, null);
								self.setElementAnimation(from, null);
								self.hideView(from);
								self.updateURL();
								self.setViewVariables(to);
							}, duration)
						}
					}
				}

				self.fadeIn = function(element, update, animation) {
					self.showViewByMediaQuery(element);

					if (update) {
						self.updateURL(element);

						element.addEventListener("animationend", function(event) {
							element.style.animation = null;
							self.setViewVariables(element);
							self.updateViewLabel();
							element.removeEventListener("animationend", arguments.callee);
						});
					}

					self.setElementAnimation(element, null);

					element.style.animation = animation;
				}

				self.fadeOutCurrentView = function(animation, update) {
					if (self.currentView) {
						self.fadeOut(self.currentView, update, animation);
					}
					if (self.currentOverlay) {
						self.fadeOut(self.currentOverlay, update, animation);
					}
				}

				self.fadeOut = function(element, update, animation) {
					if (update) {
						element.addEventListener("animationend", function(event) {
							element.style.animation = null;
							self.hideView(element);
							element.removeEventListener("animationend", arguments.callee);
						});
					}

					element.style.animationPlayState = "paused";
					element.style.animation = animation;
					element.style.animationPlayState = "running";
				}

				self.getReverseAnimation = function(animation) {
					if (animation && animation.indexOf("reverse")==-1) {
						animation += " reverse";
					}

					return animation;
				}

				/**
				 * Get duration in animation string
				 * @param {String} animation animation value
				 * @param {Boolean} inMilliseconds length in milliseconds if true
				 */
				self.getAnimationDuration = function(animation, inMilliseconds) {
					var duration = 0;
					var expression = /.+(\d\.\d)s.+/;

					if (animation && animation.match(expression)) {
						duration = parseFloat(animation.replace(expression, "$" + "1"));
						if (duration && inMilliseconds) duration = duration * 1000;
					}

					return duration;
				}

				self.setElementAnimation = function(element, animation, priority) {
					element.style.setProperty("animation", animation, "important");
				}

				self.getElement = function(id) {
					id = id ? id.trim() : id;
					var element = id ? document.getElementById(id) : null;

					return element;
				}

				self.getElementById = function(id) {
					id = id ? id.trim() : id;
					var element = id ? document.getElementById(id) : null;

					return element;
				}

				self.getElementByClass = function(className) {
					className = className ? className.trim() : className;
					var elements = document.getElementsByClassName(className);

					return elements.length ? elements[0] : null;
				}

				self.resizeHandler = function(event) {

					if (self.showByMediaQuery) {
						if (self.enableDeepLinking) {
							var stateName = self.getHashFragment();

							if (stateName==null || stateName=="") {
								var initialView = self.getInitialView();
								stateName = initialView ? self.getStateNameByViewId(initialView.id) : null;
							}
							self.showMediaQueryViewsByState(stateName, event);
						}
					}
					else {
						var visibleViews = self.getVisibleViews();

						for (let index = 0; index < visibleViews.length; index++) {
							var view = visibleViews[index];
							self.scaleViewIfNeeded(view);
						}
					}

					window.dispatchEvent(new Event(self.APPLICATION_RESIZE));
				}

				self.scaleViewIfNeeded = function(view) {

					if (self.scaleViewsOnResize) {
						if (view==null) {
							view = self.getVisibleView();
						}

						var isViewScaled = view.getAttributeNS(null, self.SIZE_STATE_NAME)=="false" ? false : true;

						if (isViewScaled) {
							self.scaleViewToFit(view, true);
						}
						else {
							self.scaleViewToActualSize(view);
						}
					}
					else if (view) {
						self.centerView(view);
					}
				}

				self.centerView = function(view) {

					if (self.scaleViewsToFit) {
						self.scaleViewToFit(view, true);
					}
					else {
						self.scaleViewToActualSize(view);  // for centering support for now
					}
				}

				self.preventDoubleClick = function(event) {
					event.stopImmediatePropagation();
				}

				self.getHashFragment = function() {
					var value = window.location.hash ? window.location.hash.replace("#", "") : "";
					return value;
				}

				self.showBlockElement = function(view) {
					view.style.display = "block";
				}

				self.hideElement = function(view) {
					view.style.display = "none";
				}

				self.showStateFunction = null;

				self.showMediaQueryViewsByState = function(state, event) {
					// browser will hide and show by media query (small, medium, large)
					// but if multiple views exists at same size user may want specific view
					// if showStateFunction is defined that is called with state fragment and user can show or hide each media matching view by returning true or false
					// if showStateFunction is not defined and state is defined and view has a defined state that matches then show that and hide other matching views
					// if no state is defined show view
					// an viewChanging event is dispatched before views are shown or hidden that can be prevented

					// get all matched queries
					// if state name is specified then show that view and hide other views
					// if no state name is defined then show
					var matchedViews = self.getMatchingViews();
					var matchMediaQuery = true;
					var foundViews = self.getViewsByStateName(state, matchMediaQuery);
					var showViews = [];
					var hideViews = [];

					// loop views that match media query
					for (let index = 0; index < matchedViews.length; index++) {
						var view = matchedViews[index];

						// let user determine visible view
						if (self.showStateFunction!=null) {
							if (self.showStateFunction(view, state)) {
								showViews.push(view);
							}
							else {
								hideViews.push(view);
							}
						}
						// state was defined so check if view matches state
						else if (foundViews.length) {

							if (foundViews.indexOf(view)!=-1) {
								showViews.push(view);
							}
							else {
								hideViews.push(view);
							}
						}
						// if no state names are defined show view (define unused state name to exclude)
						else if (state==null || state=="") {
							showViews.push(view);
						}
					}

					if (showViews.length) {
						var viewChangingEvent = new Event(self.VIEW_CHANGING);
						viewChangingEvent.showViews = showViews;
						viewChangingEvent.hideViews = hideViews;
						window.dispatchEvent(viewChangingEvent);

						if (viewChangingEvent.defaultPrevented==false) {
							for (var index = 0; index < hideViews.length; index++) {
								var view = hideViews[index];

								if (self.isOverlay(view)) {
									self.removeOverlay(view);
								}
								else {
									self.hideElement(view);
								}
							}

							for (var index = 0; index < showViews.length; index++) {
								var view = showViews[index];

								if (index==showViews.length-1) {
									self.clearDisplay(view);
									self.setViewOptions(view);
									self.setViewVariables(view);
									self.centerView(view);
									self.updateURLState(view, state);
								}
							}
						}

						var viewChangeEvent = new Event(self.VIEW_CHANGE);
						viewChangeEvent.showViews = showViews;
						viewChangeEvent.hideViews = hideViews;
						window.dispatchEvent(viewChangeEvent);
					}

				}

				self.clearDisplay = function(view) {
					view.style.setProperty("display", null);
				}

				self.hashChangeHandler = function(event) {
					var fragment = self.getHashFragment();
					var view = self.getViewById(fragment);

					if (self.showByMediaQuery) {
						var stateName = fragment;

						if (stateName==null || stateName=="") {
							var initialView = self.getInitialView();
							stateName = initialView ? self.getStateNameByViewId(initialView.id) : null;
						}
						self.showMediaQueryViewsByState(stateName);
					}
					else {
						if (view) {
							self.hideViews();
							self.showView(view);
							self.setViewVariables(view);
							self.updateViewLabel();

							window.dispatchEvent(new Event(self.VIEW_CHANGE));
						}
						else {
							window.dispatchEvent(new Event(self.VIEW_NOT_FOUND));
						}
					}
				}

				self.popStateHandler = function(event) {
					var state = event.state;
					var fragment = state ? state.name : window.location.hash;
					var view = self.getViewById(fragment);

					if (view) {
						self.hideViews();
						self.showView(view);
						self.updateViewLabel();
					}
					else {
						window.dispatchEvent(new Event(self.VIEW_NOT_FOUND));
					}
				}

				self.doubleClickHandler = function(event) {
					var view = self.getVisibleView();
					var scaleValue = view ? self.getViewScaleValue(view) : 1;
					var scaleNeededToFit = view ? self.getViewFitToViewportScale(view) : 1;
					var scaleNeededToFitWidth = view ? self.getViewFitToViewportWidthScale(view) : 1;
					var scaleNeededToFitHeight = view ? self.getViewFitToViewportHeightScale(view) : 1;
					var scaleToFitType = self.scaleToFitType;

					// Three scenarios
					// - scale to fit on double click
					// - set scale to actual size on double click
					// - switch between scale to fit and actual page size

					if (scaleToFitType=="width") {
						scaleNeededToFit = scaleNeededToFitWidth;
					}
					else if (scaleToFitType=="height") {
						scaleNeededToFit = scaleNeededToFitHeight;
					}

					// if scale and actual size enabled then switch between
					if (self.scaleToFitOnDoubleClick && self.actualSizeOnDoubleClick) {
						var isViewScaled = view.getAttributeNS(null, self.SIZE_STATE_NAME);
						var isScaled = false;

						// if scale is not 1 then view needs scaling
						if (scaleNeededToFit!=1) {

							// if current scale is at 1 it is at actual size
							// scale it to fit
							if (scaleValue==1) {
								self.scaleViewToFit(view);
								isScaled = true;
							}
							else {
								// scale is not at 1 so switch to actual size
								self.scaleViewToActualSize(view);
								isScaled = false;
							}
						}
						else {
							// view is smaller than viewport
							// so scale to fit() is scale actual size
							// actual size and scaled size are the same
							// but call scale to fit to retain centering
							self.scaleViewToFit(view);
							isScaled = false;
						}

						view.setAttributeNS(null, self.SIZE_STATE_NAME, isScaled+"");
						isViewScaled = view.getAttributeNS(null, self.SIZE_STATE_NAME);
					}
					else if (self.scaleToFitOnDoubleClick) {
						self.scaleViewToFit(view);
					}
					else if (self.actualSizeOnDoubleClick) {
						self.scaleViewToActualSize(view);
					}

				}

				self.scaleViewToFit = function(view) {
					return self.setViewScaleValue(view, true);
				}

				self.scaleViewToActualSize = function(view) {
					self.setViewScaleValue(view, false, 1);
				}

				self.onloadHandler = function(event) {
					self.initialize();
				}

				self.setElementHTML = function(id, value) {
					var element = self.getElement(id);
					element.innerHTML = value;
				}

				self.getStackArray = function(error) {
					var value = "";

					if (error==null) {
						try {
							error = new Error("Stack");
						}
						catch (e) {

						}
					}

					if ("stack" in error) {
						value = error.stack;
						var methods = value.split(/\n/g);

						var newArray = methods ? methods.map(function (value, index, array) {
							value = value.replace(/\@.*/,"");
							return value;
						}) : null;

						if (newArray && newArray[0].includes("getStackTrace")) {
							newArray.shift();
						}
						if (newArray && newArray[0].includes("getStackArray")) {
							newArray.shift();
						}
						if (newArray && newArray[0]=="") {
							newArray.shift();
						}

						return newArray;
					}

					return null;
				}

				self.log = function(value) {
					console.log.apply(this, [value]);
				}

				// initialize on load
				// sometimes the body size is 0 so we call this now and again later
				window.addEventListener("load", self.onloadHandler);
				window.document.addEventListener("DOMContentLoaded", self.onloadHandler);
			}

			window.application = new Application();
		</script>
		<div id="Sign_In">
			<svg class="Rectangle_6">
				<rect id="Rectangle_6" rx="0" ry="0" x="0" y="0" width="786" height="768">
				</rect>
			</svg>
			<div id="METADATA_u">
				<span>{"config":{},"nodeName":"- Sign in with -","type":"Group","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.399Z"}</span>
			</div>
			<div id="METADATA_i">
				<span>{"config":{},"type":"Card","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.069Z","nodeName":"Card [DISPLAY_ELEMENTS=DEFAULT]"}</span>
			</div>
			<div id="METADATA_j">
				<span>{"config":{},"nodeName":"Illustration","type":"Group","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.078Z"}</span>
			</div>
			<div id="METADATA_k">
				<span>{"config":{},"type":"Button","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.327Z","nodeName":"Button [DISPLAY_ELEMENTS=Label][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE1]"}</span>
			</div>
			<div id="METADATA_l">
				<span>{"config":{"STATE":"DEFAULT"},"type":"Icon","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.321Z","nodeName":"Icon [DISPLAY_ELEMENTS=Label][ICON=feather/heart][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE1]"}</span>
			</div>
			<div id="METADATA_m">
				<span>{"config":{"STYLE":"STYLE2"},"type":"CircleButton","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.349Z","nodeName":"Circle Button [SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_n">
				<span>{"config":{"STATE":"DEFAULT","STYLE":"STYLE2","ICON":"feather/twitter"},"type":"Icon","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.347Z","nodeName":"Icon [ICON=feather/twitter][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_o">
				<span>{"config":{"STYLE":"STYLE2"},"type":"CircleButton","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.363Z","nodeName":"Circle Button [SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_p">
				<span>{"config":{"STATE":"DEFAULT","STYLE":"STYLE2","ICON":"feather/linkedin"},"type":"Icon","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.360Z","nodeName":"Icon [ICON=feather/linkedin][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_q">
				<span>{"config":{"STYLE":"STYLE2"},"type":"CircleButton","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.373Z","nodeName":"Circle Button [SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_r">
				<span>{"config":{"STATE":"DEFAULT","STYLE":"STYLE2","ICON":"feather/facebook"},"type":"Icon","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.371Z","nodeName":"Icon [ICON=feather/facebook][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_s">
				<span>{"config":{"STYLE":"STYLE2"},"type":"CircleButton","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.388Z","nodeName":"Circle Button [SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_t">
				<span>{"config":{"STATE":"DEFAULT","STYLE":"STYLE2","ICON":"custom/google"},"type":"Icon","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.386Z","nodeName":"Icon [ICON=custom/google][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_u">
				<span>{"config":{},"nodeName":"- Sign in with -","type":"Group","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.399Z"}</span>
			</div>
			<div id="METADATA_v">
				<span>{"config":{"STATE":"ACTIVE","DISPLAY_ELEMENTS":"Label"},"type":"Checkbox","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.403Z","nodeName":"Checkbox [DISPLAY_ELEMENTS=Label][STATE=ACTIVE]"}</span>
			</div>
			<div id="METADATA_w">
				<span>{"config":{},"type":"Input","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.421Z","nodeName":"Input [DISPLAY_ELEMENTS=Default][STATE=DEFAULT]"}</span>
			</div>
			<div id="METADATA_x">
				<span>{"config":{"STATE":"DEFAULT","ICON":"Feather/Search"},"type":"Icon","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.416Z","nodeName":"Icon [DISPLAY_ELEMENTS=Default][ICON=Feather/Search][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE1]"}</span>
			</div>
			<div id="Label">
				<span>Label</span>
			</div>
			<div id="METADATA_z">
				<span>{"config":{},"type":"Input","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.436Z","nodeName":"Input [DISPLAY_ELEMENTS=Default][STATE=DEFAULT]"}</span>
			</div>
			<div id="METADATA_">
				<span>{"config":{"STATE":"DEFAULT","ICON":"Feather/Search"},"type":"Icon","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.431Z","nodeName":"Icon [DISPLAY_ELEMENTS=Default][ICON=Feather/Search][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE1]"}</span>
			</div>
			<div id="Label_">
				<span>Label</span>
			</div>
			<div id="METADATA_ba">
				<span>{"config":{"STYLE":"STYLE2"},"type":"CircleButton","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.460Z","nodeName":"Circle Button [SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<div id="METADATA_bb">
				<span>{"config":{"STATE":"DEFAULT","STYLE":"STYLE2","ICON":"feather/x"},"type":"Icon","theme":"Base","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:48:50.456Z","nodeName":"Icon [ICON=feather/x][SIZE=MEDIUM][STATE=DEFAULT][STYLE=STYLE2]"}</span>
			</div>
			<svg class="Line" viewBox="0 0 71.796 2">
				<path id="Line" d="M 0 0 L 71.79630279541016 0">
				</path>
			</svg>
			<svg class="Line_" viewBox="0 0 71.796 2">
				<path id="Line_" d="M 0 0 L 71.79630279541016 0">
				</path>
			</svg>
			<div id="Typography_TAGUI_S">
				<span>Or Sign In With</span>
			</div>
<%--			<svg class="Area_DISPLAY_ELEMENTSLabelSTAT">--%>
<%--				<rect id="Area_DISPLAY_ELEMENTSLabelSTAT" rx="0" ry="0" x="0" y="0" width="31.493" height="31.493">--%>
<%--				</rect>--%>
<%--			</svg>--%>
<%--			<svg class="Check_DISPLAY_ELEMENTSLabelSTA" viewBox="0 0 11.574 6.341">--%>
<%--				<path id="Check_DISPLAY_ELEMENTSLabelSTA" d="M 0 0 L 8.271107323348792e-16 6.34107494354248 L 11.5743579864502 6.34107494354248">--%>
<%--				</path>--%>
<%--			</svg>--%>
			<c:if test="<%= company.isAutoLogin() %>">
				<div id="Label_ba">
<%--					<span>Keep me signed in</span>--%>
					<aui:input checked="<%= rememberMe %>" name="rememberMe" type="checkbox" label="Keep me signed in"/>
				</div>
			</c:if>
<%--			<svg class="Area_DISPLAY_ELEMENTSDefaultST">--%>
<%--				<rect id="Area_DISPLAY_ELEMENTSDefaultST" rx="0" ry="0" x="0" y="0" width="302.623" height="47.665">--%>
<%--				</rect>--%>
<%--			</svg>--%>
			<div id="Value">
<%--				<span>Password</span>--%>
				<aui:input name="password" showRequiredLabel="<%= false %>" label="" type="password" value="<%= password %>" placeholder="Password">
					<aui:validator name="required" />
				</aui:input>
				<div>
					<a href="${forgotPasswordURL}"><span>Forgot Password</span></a>
				</div>
			</div>
<%--			<svg class="Area_DISPLAY_ELEMENTSDefaultST_bc">--%>
<%--				<rect id="Area_DISPLAY_ELEMENTSDefaultST_bc" rx="0" ry="0" x="0" y="0" width="302.623" height="47.665">--%>
<%--				</rect>--%>
<%--			</svg>--%>
			<div id="Value_bd">
<%--				<span>Username or email</span>--%>
				<aui:input autoFocus="<%= windowState.equals(LiferayWindowState.EXCLUSIVE) || windowState.equals(WindowState.MAXIMIZED) %>" cssClass="clearable" label="" name="login" showRequiredLabel="<%= false %>" type="text" value="<%= login %>" placeholder="Email">
					<aui:validator name="required" />

					<c:if test="<%= authType.equals(CompanyConstants.AUTH_TYPE_EA) %>">
						<aui:validator name="email" />
					</c:if>
				</aui:input>
			</div>
			<div id="Create_an_account_TAGA">
				<a href="${createAccountURL}"><span>Create an account</span></a>
			</div>
			<div id="New_user_TAGH6">
				<span>New user?</span>
			</div>
			<div id="Title_TAGH4">
				<span>Sign In</span>
			</div>
			<div id="Button">
				<div id="METADATA_bi">
					<span>{"config":{"DISPLAY_ELEMENTS":"Label+Icon"},"type":"Button","theme":"Base","nodeName":"Button","children":["78c1f1bc-07f3-495a-b67e-c9d2a37fcd3a","484695f1-557e-49fa-9f67-e299642f522b","6ca85e54-f708-43f1-91e7-d6cd0d48ef6f","4f421dd2-5939-4de6-9c50-257878e7ec96","043bf44c-4f30-463f-9c93-7ba041fda268","59cfa0ca-fc85-4fa6-b39b-4c321bd4e786","5d437475-ccfb-4df8-b2e3-9233d5143850","67578f03-620f-4e10-a299-931426e5ca31"],"__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:18:28.463Z"}</span>
				</div>
<%--				<svg class="Area">--%>
<%--					<rect id="Area" rx="32.76953125" ry="32.76953125" x="0" y="0" width="302.623" height="65.539">--%>
<%--					</rect>--%>
<%--				</svg>--%>
				<div id="Label_bk">
					<span><aui:button type="submit" value="sign-in" /></span>
				</div>
			</div>
			<div id="Button_bl">
				<div id="METADATA_bm">
					<span>{"config":{"DISPLAY_ELEMENTS":"Label+Icon"},"type":"Button","theme":"Base","nodeName":"Button","children":["78c1f1bc-07f3-495a-b67e-c9d2a37fcd3a","484695f1-557e-49fa-9f67-e299642f522b","6ca85e54-f708-43f1-91e7-d6cd0d48ef6f","4f421dd2-5939-4de6-9c50-257878e7ec96","043bf44c-4f30-463f-9c93-7ba041fda268","59cfa0ca-fc85-4fa6-b39b-4c321bd4e786","5d437475-ccfb-4df8-b2e3-9233d5143850","67578f03-620f-4e10-a299-931426e5ca31"],"__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T22:18:28.463Z"}</span>
				</div>
				<svg class="Area_bn">
					<rect id="Area_bn" rx="0" ry="0" x="0" y="0" width="303.648" height="65.539">
					</rect>
				</svg>
				<div id="Label_bo">
					<span>Sign In With SSO</span>
				</div>
				<div id="Icon">
					<div id="METADATA_bq">
						<span>{"config":{"ICON":"line-awesome/lock-solid"},"type":"Icon","theme":"Base","nodeName":"Icon","__plugin":"Mockup","__version":"1.5.0","__lastUpdate":"2022-03-29T23:00:21.380Z"}</span>
					</div>
					<svg class="Area_br">
						<rect id="Area_br" rx="0" ry="0" x="0" y="0" width="17.023" height="17.023">
						</rect>
					</svg>
					<div id="Icon_bs">
						<svg class="bdca5121-645a-4f40-a71f-09e5c3" viewBox="3.928 1.964 13.095 17.023">
							<path id="bdca5121-645a-4f40-a71f-09e5c3" d="M 10.47599983215332 1.96399998664856 C 7.959000110626221 1.96399998664856 5.89300012588501 4.031000137329102 5.89300012588501 6.546999931335449 L 5.89300012588501 8.51200008392334 L 3.927999973297119 8.51200008392334 L 3.927999973297119 18.98699951171875 L 17.02300071716309 18.98699951171875 L 17.02300071716309 8.51200008392334 L 15.05900001525879 8.51200008392334 L 15.05900001525879 6.546999931335449 C 15.05900001525879 4.031000137329102 12.99199962615967 1.96399998664856 10.47599983215332 1.96399998664856 Z M 10.47599983215332 3.273999929428101 C 12.2790002822876 3.273999929428101 13.74899959564209 4.74399995803833 13.74899959564209 6.546999931335449 L 13.74899959564209 8.51200008392334 L 7.202000141143799 8.51200008392334 L 7.202000141143799 6.546999931335449 C 7.202000141143799 4.74399995803833 8.673000335693359 3.273999929428101 10.47599983215332 3.273999929428101 Z M 5.23799991607666 9.821000099182129 L 15.71399974822998 9.821000099182129 L 15.71399974822998 17.67799949645996 L 5.23799991607666 17.67799949645996 L 5.23799991607666 9.821000099182129 Z">
							</path>
						</svg>
					</div>
				</div>
			</div>
<%--			<div id="Group_4">--%>
<%--				<img id="Group_3" src="Group_3.png" srcset="Group_3.png 1x, Group_3@2x.png 2x">--%>

<%--				</svg>--%>
<%--			</div>--%>
<%--			<div id="Group_6">--%>
<%--				<img id="Group_5" src="Group_5.png" srcset="Group_5.png 1x, Group_5@2x.png 2x">--%>

<%--				</svg>--%>
<%--			</div>--%>
			<div id="Welcome_To_Our_Employee_Portal">
				<span>Welcome To Our Employee Portal</span>
			</div>
<%--			<div id="Create_an_account_TAGA_bz">--%>
<%--				<span>Forgot Username</span>--%>
<%--			</div>--%>
<%--			<div id="Create_an_account_TAGA_b">--%>
<%--				<a href="${forgotPasswordURL}"><span>Forgot Password</span></a>--%>
<%--			</div>--%>
		</div>
		<span id="<portlet:namespace />passwordCapsLockSpan" style="display: none;"><liferay-ui:message key="caps-lock-is-on" /></span>
	</aui:fieldset>
</aui:form>

		<aui:script sandbox="<%= true %>">
			var form = document.getElementById('<portlet:namespace /><%= formName %>');

			if (form) {
				form.addEventListener('submit', (event) => {
					<c:if test="<%= PropsValues.SESSION_ENABLE_PERSISTENT_COOKIES && PropsValues.SESSION_TEST_COOKIE_SUPPORT %>">
						if (!navigator.cookieEnabled) {
							document.getElementById(
								'<portlet:namespace />cookieDisabled'
							).style.display = '';

							return;
						}
					</c:if>

					<c:if test="<%= Validator.isNotNull(redirect) %>">
						var redirect = form.querySelector('#<portlet:namespace />redirect');

						if (redirect) {
							var redirectVal = redirect.getAttribute('value');

							redirect.setAttribute('value', redirectVal + window.location.hash);
						}
					</c:if>

					submitForm(form);
				});

				var password = form.querySelector('#<portlet:namespace />password');

				if (password) {
					password.addEventListener('keypress', (event) => {
						Liferay.Util.showCapsLock(
							event,
							'<portlet:namespace />passwordCapsLockSpan'
						);
					});
				}
			}
		</aui:script>
	</c:otherwise>
</c:choose>